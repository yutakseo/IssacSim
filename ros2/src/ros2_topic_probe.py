#!/usr/bin/env python3
import argparse

import rclpy
from rclpy.node import Node


class TopicProbe(Node):
    def __init__(self) -> None:
        super().__init__("external_topic_probe")

    def print_topics(self) -> None:
        topics = sorted(self.get_topic_names_and_types())
        if not topics:
            self.get_logger().info("No ROS 2 topics discovered.")
            return

        self.get_logger().info("Discovered ROS 2 topics:")
        for name, types in topics:
            self.get_logger().info(f"  {name}: {types}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Print visible ROS 2 topics.")
    parser.add_argument(
        "--wait",
        type=float,
        default=2.0,
        help="Seconds to wait for DDS discovery before printing.",
    )
    args = parser.parse_args()

    rclpy.init()
    node = TopicProbe()
    try:
        node.get_logger().info(f"Waiting {args.wait:.1f}s for DDS discovery...")
        rclpy.spin_once(node, timeout_sec=args.wait)
        node.print_topics()
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
