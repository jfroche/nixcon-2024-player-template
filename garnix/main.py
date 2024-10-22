from fastapi import FastAPI  
import os
import uvicorn

app = FastAPI()

@app.get("/")
async def main_route() -> str:
  return "Hello Garnix"

@app.get('/add/{a}/{b}')
async def add(a: int, b: int) -> int:
  return a + b

@app.get('/mult/{a}/{b}')
async def mult(a: int, b: int) -> int:
  return a * b

def start():
  port = os.getenv("PORT", 8001)
  uvicorn.run("garnix.main:app", host="0.0.0.0", port=int(port), reload=True)

if __name__ == "__main__":
  start()
