#!/usr/bin/env python3
import argparse
import time

import rclpy
from geometry_msgs.msg import Twist
from rclpy.node import Node


class CmdVelPublisher(Node):
    def __init__(self, topic: str) -> None:
        super().__init__("external_cmd_vel_publisher")
        self.publisher = self.create_publisher(Twist, topic, 10)

    def publish(self, linear_x: float, angular_z: float) -> None:
        msg = Twist()
        msg.linear.x = linear_x
        msg.angular.z = angular_z
        self.publisher.publish(msg)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Publish geometry_msgs/Twist for Isaac Sim external control."
    )
    parser.add_argument("--topic", default="/cmd_vel", help="Twist topic name")
    parser.add_argument("--linear-x", type=float, default=0.5, help="Linear x velocity")
    parser.add_argument("--angular-z", type=float, default=0.0, help="Angular z velocity")
    parser.add_argument("--rate", type=float, default=10.0, help="Publish rate in Hz")
    parser.add_argument("--duration", type=float, default=3.0, help="Publish duration in seconds")
    args = parser.parse_args()

    rclpy.init()
    node = CmdVelPublisher(args.topic)
    period = 1.0 / args.rate
    total = max(1, int(args.duration * args.rate))

    node.get_logger().info(
        f"Publishing Twist to {args.topic} at {args.rate:.1f} Hz for {args.duration:.1f} s"
    )
    node.get_logger().info(
        f"linear.x={args.linear_x:.3f}, angular.z={args.angular_z:.3f}"
    )

    try:
        for _ in range(total):
            node.publish(args.linear_x, args.angular_z)
            rclpy.spin_once(node, timeout_sec=0.0)
            time.sleep(period)
    finally:
        node.get_logger().info("Finished publishing Twist.")
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
