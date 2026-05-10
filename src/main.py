from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "UP"}


handler = Mangum(app)