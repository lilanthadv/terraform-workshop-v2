# AWS SQS Queue Module

This Terraform configuration creates an AWS SQS queue.

## Usage

main.tf

## Inputs

| Name                        | Description                                                                                            | Type   | Default        | Required |
| --------------------------- | ------------------------------------------------------------------------------------------------------ | ------ | -------------- | -------- |
| app_name                    | The name of the application.                                                                           | string | n/a            | yes      |
| fifo_queue                  | Specifies whether the queue is FIFO (true) or standard (false). Defaults to false.                     | bool   | false          | no       |
| deduplication_scope         | The scope of deduplication for FIFO queues. Possible values are "messageGroup" or "queue".             | string | "messageGroup" | no       |
| fifo_throughput_limit       | Specifies whether the FIFO queue throughput is limited (true) or unlimited (false). Defaults to false. | bool   | false          | no       |
| visibility_timeout_seconds  | The visibility timeout for the queue, in seconds. Defaults to 30.                                      | number | 30             | no       |
| delay_seconds               | The delay time for new messages, in seconds. Defaults to 0.                                            | number | 0              | no       |
| max_message_size            | The maximum allowed message size, in bytes. Defaults to 262144 (256 KiB).                              | number | 262144         | no       |
| message_retention_seconds   | The number of seconds to retain messages in the queue. Defaults to 345600 (4 days).                    | number | 345600         | no       |
| receive_wait_time_seconds   | The time for which a ReceiveMessage action waits for a message to arrive. Defaults to 0.               | number | 0              | no       |
| content_based_deduplication | Specifies whether to enable content-based deduplication for the queue. Defaults to false.              | bool   | false          | no       |

## Outputs

| Name      | Description                       |
| --------- | --------------------------------- |
| queue_url | The URL of the created SQS queue. |
