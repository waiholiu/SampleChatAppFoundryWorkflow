import os
from flask import Flask, render_template, request, jsonify, session
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.core.rest import HttpRequest
from dotenv import load_dotenv

load_dotenv(override=False)

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", os.urandom(32).hex())

PROJECT_ENDPOINT = os.environ["PROJECT_ENDPOINT"]
AGENT_NAME = os.environ["AGENT_NAME"]
TENANT_ID = os.environ.get("AZURE_TENANT_ID")


def _get_project_client() -> AIProjectClient:
    cred = DefaultAzureCredential(
        additionally_allowed_tenants=[TENANT_ID] if TENANT_ID else []
    )
    return AIProjectClient(
        endpoint=PROJECT_ENDPOINT, credential=cred, allow_preview=True
    )


def _create_conversation(client: AIProjectClient) -> str:
    req = HttpRequest("POST", "/conversations?api-version=v1", json={})
    resp = client.send_request(req)
    resp.raise_for_status()
    return resp.json()["id"]


@app.route("/")
def index():
    return render_template("index.html", agent_name=AGENT_NAME)


@app.route("/api/chat", methods=["POST"])
def chat():
    body = request.get_json()
    user_message = body.get("message", "").strip()
    if not user_message:
        return jsonify({"error": "Empty message"}), 400

    client = _get_project_client()
    oai = client.get_openai_client()

    conv_id = session.get("conv_id")
    if not conv_id:
        conv_id = _create_conversation(client)
        session["conv_id"] = conv_id

    resp = oai.responses.create(
        input=user_message,
        extra_body={
            "agent_reference": {
                "name": AGENT_NAME,
                "type": "agent_reference",
            },
            "conversation": conv_id,
        },
    )

    return jsonify({"reply": resp.output_text, "conversation_id": conv_id})


@app.route("/api/reset", methods=["POST"])
def reset():
    session.pop("conv_id", None)
    return jsonify({"ok": True})


if __name__ == "__main__":
    app.run(debug=True, port=5000)
