import base64
import datetime
import logging
import subprocess

from flask import Flask, request

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__file__)


@app.route("/", methods=["POST"])
def index():
    pubsub_event = request.get_json()
    logger.info(pubsub_event)
    message = pubsub_event["message"]
    message_id = message["message_id"]
    logger.info(f'receive message {message_id}')

    message_attributes = message.get("attributes")
    if message_attributes is None:
        message_attributes = {}

    # message validation.
    if not message.get('data'):
        logger.info(f'message data is none or empty.')
        return "", 400

    command = str(base64.b64decode(message.get('data')).decode("utf-8").strip())

    # cloud command options that can be overwrite.
    gcloud_command_options = {
        'network': 'default',
        'subnet': 'default',
        'machine_type': 'n1-standard-1',
        'service_account': 'default',
        'scopes': 'https://www.googleapis.com/auth/cloud-platform',
        'zone': 'asia-northeast1-a',
        'maintenance_policy': 'MIGRATE',
        'image_family': 'cos-stable',
        'image_project': 'cos-cloud',
        'boot_disk_size': '10GB',
        'metadata_from_file': 'startup-script=./gce_startup.sh'
    }

    # update args from pubsub message attributes.
    for key in gcloud_command_options.keys():
        if key in message_attributes:
            gcloud_command_options[key] = message_attributes.get(key)

    # instance name
    instance_prefix = 'gcp-container-batch'
    epoc_second = int(datetime.datetime.now(datetime.timezone.utc).timestamp())
    instance_name = f'{instance_prefix}-{epoc_second}'

    # disk name
    gcloud_command_options['boot_disk_device_name'] = f'{instance_name}-disk'

    # timeout_second
    timeout_second = '1800'
    if message_attributes.get('timeout_second'):
        timeout_second = message_attributes.get('timeout_second')

    # add metadata (image name and command)
    gcloud_command_options['metadata'] = f'image_name={message_attributes["image_name"]},container_param=\'{command}\''

    # build gcloud command array.
    gcloud_command_array = ['gcloud', 'compute', 'instances', 'create', instance_name]
    for key in gcloud_command_options.keys():
        parameter_name = f"--{key.replace('_', '-')}"
        parameter_value = gcloud_command_options[key]
        gcloud_command_array.append(f'{parameter_name}={parameter_value}')

    # add timeout_second
    gcloud_command_array.append(f'--tags=timeout-second-{timeout_second}')

    # call gcloud command.
    logger.info('call gcloud command.')
    logger.info(' '.join(gcloud_command_array))
    subprocess.call(' '.join(gcloud_command_array), shell=True)
    logger.info('finish gcloud command.')

    return "", 204
