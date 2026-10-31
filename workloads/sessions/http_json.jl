# env: data
# kind: interactive
# about: Web-service session: serve JSON on localhost, query it, parse and tabulate results.

# %% load
using HTTP, JSON3, DataFrames

# %% serve
items = [Dict("id" => i, "name" => "item$i", "price" => round(i * 1.37; digits=2)) for i in 1:200]
router = HTTP.Router()
HTTP.register!(router, "GET", "/items", req -> HTTP.Response(200, JSON3.write(items)))
HTTP.register!(router, "GET", "/items/{id}", function (req)
    id = parse(Int, HTTP.getparams(req)["id"])
    return HTTP.Response(200, JSON3.write(items[id]))
end)
HTTP.register!(router, "POST", "/echo", req -> HTTP.Response(200, req.body))
server = HTTP.serve!(router, "127.0.0.1", 0)
port = HTTP.port(server)

# %% get
resp = HTTP.get("http://127.0.0.1:$port/items")
resp.status

# %% parse
data = JSON3.read(resp.body)
length(data)

# %% tabulate
df = DataFrame(data)
first(sort(df, :price; rev=true), 5)

# %% one item
JSON3.read(HTTP.get("http://127.0.0.1:$port/items/42").body)

# %% post
r = HTTP.post("http://127.0.0.1:$port/echo", ["Content-Type" => "application/json"],
    JSON3.write((; query="fig", limit=3)))
JSON3.read(r.body)

# %% many requests
[HTTP.get("http://127.0.0.1:$port/items/$i").status for i in 1:50] |> unique

# %% stop
close(server)
