from flask import Flask

app = Flask(__name__)

@app.get("/health")
def health():
    return {"status": "ok"}, 200

@app.route('/')
def hello():
    return "Hello from my AWS DevOps Project! Deployed automatically with Bash. Built by Hardik 🚀"

if __name__ == '__main__':
    #app.run(host='0.0.0.0', port=80, debug=False)
    app.run(host='0.0.0.0', port=5000)