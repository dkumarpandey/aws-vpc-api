from fastapi import FastAPI, HTTPException
from mangum import Mangum

from models import CreateVpcRequest
from vpc_service import create_vpc
from dynamodb_service import save_vpc, get_vpc

app = FastAPI(
    title="AWS FastAPI VPC API",
    version="1.0.0",
    root_path="/Prod"
)


@app.get("/")
def root():

    return {
        "message": "AWS VPC API is running"
    }

@app.get("/health")
def health():

    return {
        "status": "UP"
    }


@app.post("/network")
def create_network(request: CreateVpcRequest):

    try:

        result = create_vpc(
            request.dict()
        )

        save_vpc(result)

        return {
            "message": "VPC created successfully",
            "data": result
        }

    except Exception as ex:

        raise HTTPException(
            status_code=500,
            detail=str(ex)
        )


@app.get("/network/{vpc_id}")
def get_network(vpc_id: str):

    data = get_vpc(vpc_id)

    if not data:

        raise HTTPException(
            status_code=404,
            detail=f"VPC not found: {vpc_id}"
        )

    return data


handler = Mangum(app)