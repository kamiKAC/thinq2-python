from uplink import Field, Path, Query
from uplink import get, post, delete, json, response_handler

from thinq2.client.base import BaseClient
from thinq2.model.thinq import (
    DeviceCollection,
    DeviceDescriptor,
    ThinQResult,
    ThinQResultSuccess,
    IOTRegistration,
    ModelJsonDescriptor,
)

class UnsuccessfulRequest(Exception):
    """Raised when an HTTP request fails."""
    def __init__(self, url, status_code, message="HTTP Request Error"):
        self.url = url
        self.status_code = status_code
        self.message = message
        super().__init__(self.message)
    def __str__(self):
      return f"{self.message}.\nURL: {self.url}\nStatus Code: {self.status_code}"

def raise_for_status(response):
    """Checks whether or not the response was successful."""
    if 200 <= response.status_code < 300:
        # Pass through the response.
        return response

    raise UnsuccessfulRequest( response.url, response.status_code, "400 - maybe you have to accept new terms and condition in LG ThinQ app?" if response.status_code == 400 else "HTTP Request Error")

class ThinQClient(BaseClient):
    """LG ThinQ API client"""

    @response_handler(raise_for_status)
    @get("service/application/dashboard")
    def get_devices(self) -> ThinQResult(DeviceCollection):
        """Retrieves collection of user's registered devices with dashboard data."""

    @get("service/devices/{device_id}")
    def get_device(self, device_id: Path) -> ThinQResult(DeviceDescriptor):
        """Retrieves an individual device"""

    @get("service/application/modeljson")
    def get_model_json_descriptor(
        self, device_id: Query("deviceId"), model_name: Query("modelName")
    ) -> ThinQResult(ModelJsonDescriptor):
        """Retrieves ModelJson descriptor for a device"""

    @get("service/users/client")
    def get_registered(self) -> ThinQResultSuccess():
        """Get client registration status"""

    @post("service/users/client")
    def register(self) -> ThinQResultSuccess():
        """Register client ID"""

    @delete("service/users/client")
    def deregister(self) -> ThinQResultSuccess():
        """Deregister client ID"""

    @json
    @post("service/users/client/certificate")
    def register_iot(self, csr: Field) -> ThinQResult(IOTRegistration):
        """Register an IoT/MQTT session, given a csr"""
