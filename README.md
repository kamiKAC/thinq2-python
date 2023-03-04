# thinq2-python

This is a reverse-engineered client for the LG ThinQ v2 IoT protocol. 

If you are working with v1 devices, try [wideq](https://github.com/sampsyo/wideq),
which inspired this project.

## Work in progress!

This is very much a **work in progress**.

There are no unit tests, there is no documentation, there is no defined API and
breaking changes are almost guaranteed to happen. Fun times!

## Development

This project uses [poetry](https://python-poetry.org/) for dependency management.

To configure a development environment, run `poetry install`.

## Running the Example

There is currently no documentation, but you can use `example.py` to demo the
codebase, and its code shows basic usage. The `COUNTRY_CODE` and `LANGUAGE_CODE`
environment variables should be set appropriately on first invocation in order
to bootstrap the client. These will be stored in state for future invocations.

Example:

    poetry install
    COUNTRY_CODE=US LANGUAGE_CODE=en-US poetry run python example.py

Example (Windows Powershell):

    $env:COUNTRY_CODE=US
    $env:LANGUAGE_CODE=en-US
    poetry run python example.py

The example script will bootstrap the application state on first run, walking
you through the OAuth flow. If authentication succeeds, you should see a
display of basic account information and a list of your ThinQv2 devices. The
script will then begin dumping device events received via MQTT. Try turning
devices on/off or otherwise changing their state, and you should see raw events
being sent.


## Contributing

As this is an early stage prototype, no contribution guidelines are available,
but help is always welcome!

## New functionalities

Added code to map LG device events into MQTT topics (thanks to Flip76 https://github.com/Flip76/thinq2_mqtt/).
Example:

    poetry install
    COUNTRY_CODE=US LANGUAGE_CODE=en-US poetry run python thinq2_mqtt.py
    
Other configuration variables:
<ul>
<li>MQTT_CLIENT_NAME - name of the MQTTclient (default 'thinq_mqtt')
<li>MQTT_HOST - hostname or ip address of MQTT server (default 'localhost')
<li>MQTT_PORT - port of MQTT server (default '1883')
<li>MQTT_TOPIC - topic to which events will be stored to (default 'thinq')
<li>MQTT_USER - username for MQTT authentication (empty by default)
<li>MQTT_PASS - possword for MQTT authentication (empty by default)
<li>MQTT_QOS - qos level (default '2')
</ul>
    
Added Dockerfile to create docker image so service can run in container:

    git clone https://github.com/kamiKAC/thinq2-python/
    cd thinq2-python
    docker build -ti thinq2_mqtt:1.0
    mkdir -p state
    docker run -ti -e COUNTRY_CODE=US -e LANGUAGE_CODE=en-US -v ./state/:/thinq2-python/state/ thinq2-mqtt:1.0

After initial configuration start docker in daemon mode:

    docker run -d --name thinq2_mqtt -e COUNTRY_CODE=US -e LANGUAGE_CODE=en-US -v ./state/:/thinq2-python/state/ thinq2-mqtt:1.0

To stop container:

    docker stop thinq2_mqtt

