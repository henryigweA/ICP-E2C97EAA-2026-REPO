from flask import Flask, jsonify, request

app = Flask(__name__)

# In-memory store: resets whenever the process restarts.
products = [{"id": 1, "name": "Widget", "qty": 10}]


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/products")
def list_products():
    return jsonify(products)


@app.post("/products")
def add_product():
    data = request.get_json(silent=True) or {}
    if "name" not in data:
        return jsonify(error="name is required"), 400
    item = {"id": len(products) + 1, "name": data["name"], "qty": data.get("qty", 0)}
    products.append(item)
    return jsonify(item), 201


@app.get("/products/<int:pid>")
def get_product(pid):
    for p in products:
        if p["id"] == pid:
            return jsonify(p)
    return jsonify(error="not found"), 404


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
