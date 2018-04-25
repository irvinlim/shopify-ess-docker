# Shopify Enterprise Script Service (ESS)

Dockerfile for [Shopify/ess](https://github.com/Shopify/ess) (also known as Shopify Scripts) to execute untrusted Ruby scripts in a sandbox.

## Usage

In the directory where your script is located, you can simply run the container as follows, assuming that `yourscript.rb` is the name of the Ruby script you wish to execute:

```sh
docker run --rm -v "$PWD:/scripts" irvinlim/shopify-ess:latest pretty yourscript.rb
```

Alternatively, to pass a script via stdin, run the container in interactive mode with `-i`:

```sh
echo "@output = 25 + 10" | docker run --rm -i irvinlim/shopify-ess:latest pretty
```

The `pretty` executable produces prettified output to your terminal. If you need a parseable format, JSON is available through the `json` command as well. 

Alternatively, you can also fall back to the `sandbox` executable [as provided by Shopify](https://github.com/Shopify/ess/blob/master/bin/sandbox), which produces the unformatted Ruby `#<struct ...>` output.

## License

MIT
