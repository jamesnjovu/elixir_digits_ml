defmodule AppWeb.IndexLive do
    use AppWeb, :live_view
  
    @impl true
    def render(assigns) do
      ~H"""
      <div id="wrapper" phx-update="ignore">
        <div id="canvas" phx-hook="Draw"></div>
      </div>
    
      <div>
        <button phx-click="reset">Reset</button>
        <button phx-click="predict">Predict</button>
      </div>
    
      <%= if @prediction do %>
      <div>
        <div>
          Prediction:
        </div>
        <div>
          <%= @prediction %>
        </div>
      </div>
      <% end %>
      """
    end
    
    @impl true
    def mount(_, _, socket) do
      {:ok, assign(socket, %{prediction: nil})}
    end

    def handle_event("reset", _params, socket) do
      {:noreply,
        socket
        |> assign(prediction: nil)
        |> push_event("reset", %{})
      }
    end

    def handle_event("predict", _params, socket) do
      {:noreply, push_event(socket, "predict", %{})}
    end

    def handle_event("image", "data:image/png;base64," <> raw, socket) do
      name = Base.url_encode64(:crypto.strong_rand_bytes(10), padding: false)
      path = Path.join(System.tmp_dir!(), "#{name}.webp")
    
      File.write!(path, Base.decode64!(raw))
    
      prediction = App.Model.predict(path)
    
      File.rm!(path)
    
      {:noreply, assign(socket, prediction: prediction)}
    end
  end
  