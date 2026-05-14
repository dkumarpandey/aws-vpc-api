from fastapi import FastAPI
from mangum import Mangum

from models import CreateVpcRequest
from workflow.start_execution import start_provisioning
from workflow.status_service import get_status

app = FastAPI(
    title="AWS VPC Provisioning API",
    version="2.0.0"
)


@app.get("/health")
def health():
    return {
        "status": "UP"
    }


@app.post("/network")
def create_network(request: CreateVpcRequest):

    return start_provisioning(
        #request.model_dump()
        request.dict()
    )


@app.get("/network/status/{request_id}")
def network_status(request_id: str):

    return get_status(request_id)


handler = Mangum(
    app,
    lifespan="off"
)