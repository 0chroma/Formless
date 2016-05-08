FROM trenpixster/elixir:1.2.0

# Set exposed ports
EXPOSE 8080
VOLUME ["/app/config", "/app/data"]
ENV MIX_ENV=prod

# Set your project's working directory
WORKDIR /app

# Same with elixir deps
ADD mix.exs ./
ADD config/config.exs config/prod.exs ./config/

RUN mix do deps.get, deps.compile

ADD lib data test README.md LICENSE ./

# Run compile
RUN mix compile

CMD ["mix", "run", "--no-halt"]
