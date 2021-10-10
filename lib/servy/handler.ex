defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms the request into a response."
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    
    request 
    |> parse 
    |> rewrite_path
    |> log
    |> route 
    |> track
    |> format_response
  end

  # def route(conv) do
  #   route(conv, conv.method, conv.path)
  # end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    file = 
      Path.expand("../../pages", __DIR__)
      |> Path.join("form.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{ conv | status: 403, resp_body: "deleting a bear is forbidden" }
  end

  def route(%{method: "GET", path: "/about.html"} = conv) do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/pages/" <> file} = conv) do
      @pages_path
      |> Path.join(file <> ".html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%{path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      402 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /about.html HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
