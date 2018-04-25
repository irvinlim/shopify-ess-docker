require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", Pathname.new(__FILE__).realpath)

require "rubygems"
require "bundler/setup"
require "enterprise_script_service"

# TODO: Optionally pass quotas via Docker environment variables.
MEMORY_QUOTA = 8 << 20
INSTRUCTION_QUOTA = 200_000
TIME_QUOTA = 1.0

def run(script_name)
  # Read file either from filename or stdin.
  script_name ||= "/dev/stdin"
  script = File.read(script_name)

  # Execute the script in the sandbox.
  result = EnterpriseScriptService.run(
    input: {},
    sources: [
      ["(input)", script],
    ],
    instructions: nil,
    timeout: TIME_QUOTA,
    instruction_quota: INSTRUCTION_QUOTA,
    instruction_quota_start: 0,
    memory_quota: MEMORY_QUOTA
  )
end

def get_quotas
  {
    "memory" => MEMORY_QUOTA,
    "instruction" => INSTRUCTION_QUOTA,
    "time" => TIME_QUOTA,
  }
end
