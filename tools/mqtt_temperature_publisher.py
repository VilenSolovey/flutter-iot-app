from __future__ import annotations

import argparse
import random
import sys
import time
from datetime import datetime

import paho.mqtt.client as mqtt


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description='Simulate temperature and heart rate sensors over MQTT.',
    )
    parser.add_argument(
        '--host',
        default='localhost',
        help='MQTT broker host. Default: localhost',
    )
    parser.add_argument(
        '--port',
        type=int,
        default=1883,
        help='MQTT broker port. Default: 1883',
    )
    parser.add_argument(
        '--topic',
        default='sensor/temperature',
        help='Temperature MQTT topic. Default: sensor/temperature',
    )
    parser.add_argument(
        '--heart-rate-topic',
        default='sensor/heart_rate',
        help='Heart rate MQTT topic. Default: sensor/heart_rate',
    )
    parser.add_argument(
        '--interval',
        type=float,
        default=2.0,
        help='Publish interval in seconds. Default: 2.0',
    )
    parser.add_argument(
        '--min-temp',
        type=float,
        default=36.45,
        help='Minimum simulated temperature. Default: 36.45',
    )
    parser.add_argument(
        '--max-temp',
        type=float,
        default=36.95,
        help='Maximum simulated temperature. Default: 36.95',
    )
    parser.add_argument(
        '--client-id',
        default=f'python-sensor-publisher-{int(time.time())}',
        help='MQTT client id.',
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.interval <= 0:
        print('Interval must be greater than 0.', file=sys.stderr)
        return 1

    if args.min_temp > args.max_temp:
        print('min-temp cannot be greater than max-temp.', file=sys.stderr)
        return 1

    client = mqtt.Client(
        callback_api_version=mqtt.CallbackAPIVersion.VERSION2,
        client_id=args.client_id,
    )

    try:
        client.connect(args.host, args.port, keepalive=20)
    except Exception as error:  # noqa: BLE001
        print(
            f'Failed to connect to MQTT broker at {args.host}:{args.port}: '
            f'{error}',
            file=sys.stderr,
        )
        return 1

    client.loop_start()
    print(
        f'Publishing simulated sensor data to {args.host}:{args.port}',
    )
    print('Press Ctrl+C to stop.')

    heart_rate = random.randint(68, 74)
    temperature = round(random.uniform(args.min_temp, args.max_temp), 2)
    try:
        while True:
            temperature = round(
                max(
                    args.min_temp,
                    min(
                        args.max_temp,
                        temperature + random.uniform(-0.04, 0.04),
                    ),
                ),
                2,
            )
            heart_rate = max(66, min(78, heart_rate + random.choice((-1, 0, 1))))

            temperature_payload = f'{temperature:.2f}'
            heart_rate_payload = str(heart_rate)

            temperature_result = client.publish(args.topic, temperature_payload)
            temperature_result.wait_for_publish()

            heart_rate_result = client.publish(
                args.heart_rate_topic,
                heart_rate_payload,
            )
            heart_rate_result.wait_for_publish()

            timestamp = datetime.now().strftime('%H:%M:%S')
            print(
                f'[{timestamp}] Temperature {temperature_payload} -> '
                f'{args.topic}; Heart rate {heart_rate_payload} -> '
                f'{args.heart_rate_topic}',
            )
            time.sleep(args.interval)
    except KeyboardInterrupt:
        print('\nStopped publisher.')
    finally:
        client.loop_stop()
        client.disconnect()

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
