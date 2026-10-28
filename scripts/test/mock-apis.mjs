#!/usr/bin/env node

import http from "node:http";

const port = Number(process.env.MOCK_API_PORT || 41731);

function send(response, status, body) {
  response.writeHead(status, { "content-type": "application/json" });
  response.end(JSON.stringify(body));
}

function acceptsFakeKey(request) {
  const authorization = request.headers.authorization || "";
  return authorization.startsWith("Bearer FAKE_");
}

const server = http.createServer(async (request, response) => {
  if (!acceptsFakeKey(request)) {
    send(response, 401, { error: "Unauthorized" });
    return;
  }

  if (request.method === "GET" && request.url === "/fb/page/getInfo") {
    send(response, 200, {
      status: "success",
      data: { name: "Demo ManyChat Page", username: "demopage", is_pro: true },
    });
    return;
  }

  if (request.method === "POST" && request.url === "/") {
    let body = "";
    for await (const chunk of request) body += chunk;
    let query = "";
    try {
      query = JSON.parse(body).query || "";
    } catch {
      send(response, 400, { errors: [{ message: "Invalid request" }] });
      return;
    }

    if (query.includes("DoctorOrganizations")) {
      send(response, 200, { data: { account: { organizations: [{ id: "demo-org", name: "Demo Organization" }] } } });
      return;
    }
    if (query.includes("DoctorChannels")) {
      send(response, 200, {
        data: {
          channels: [{
            name: "demo.broker",
            displayName: "Demo Broker",
            service: "instagram",
            externalLink: "https://instagram.com/demo.broker",
            isDisconnected: false,
            isLocked: false,
            isQueuePaused: false,
            timezone: "America/New_York",
            type: "business",
          }],
        },
      });
      return;
    }
  }

  send(response, 404, { error: "Not found" });
});

server.listen(port, "127.0.0.1", () => {
  console.log(`Mock APIs ready at http://127.0.0.1:${port}`);
});

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => server.close(() => process.exit(0)));
}
