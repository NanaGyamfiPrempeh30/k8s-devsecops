from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI(title="Task API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Task Management API", "version": "1.0"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/tasks")
def get_tasks():
    return {
        "tasks": [
            {"id": 1, "title": "Deploy Kubernetes", "status": "completed"},
            {"id": 2, "title": "Setup Vault", "status": "completed"},
            {"id": 3, "title": "Configure Monitoring", "status": "completed"}
        ]
    }
