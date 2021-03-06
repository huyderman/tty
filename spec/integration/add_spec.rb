# encoding: utf-8

RSpec.describe 'teletype add', type: :cli do
  it "adds a command" do
    app_name = tmp_path('newcli')
    silent_run("bundle exec teletype new #{app_name}")

    # create newcli/spec/integration/server_spec.rb
    # insert newcli/lib/newcli/cli.rb
    output = <<-OUT
      create  lib/newcli/commands/server.rb
    OUT

    within_dir(app_name) do
      command = "bundle exec teletype add server --no-color"

      out, err, status = Open3.capture3(command)

      expect(out).to match(output)
      expect(err).to eq('')
      expect(status.exitstatus).to eq(0)

      # lib/newcli/commands/server.rb
      #
      expect(::File.read('lib/newcli/commands/server.rb')).to match <<-EOS
# encoding: utf-8
# frozen_string_literal: true

require_relative '../cmd'

module Newcli
  module Commands
    class Server < Newcli::Cmd
      def initialize(options)
        @options = options
      end

      def execute
        # Command logic goes here ...
      end
    end
  end
end
      EOS
    end
  end

  it "fails without command name" do
    output = <<-OUT.unindent
      ERROR: 'teletype add' was called with no arguments
      Usage: 'teletype add COMMAND_NAME'\n
    OUT
    command = "bundle exec teletype add"
    out, err, status = Open3.capture3(command)
    expect([out, err, status.exitstatus]).to match_array([output, '', 1])
  end

  it "displays help" do
    output = <<-OUT
Usage:
  teletype add COMMAND_NAME [OPTIONS]

Options:
  -h, [--help=HELP]                # Dispaly usage information.
      [--no-color]                 # Disable colorization in output.
  -r, [--dry-run], [--no-dry-run]  # Run but do not make any changes.
      [--debug], [--no-debug]      # Run with debug logging.

Description:
  The `teletype add` will create a new command and place it into appropriate 
  structure in the cli app.

  Example: teletype add config

  This generates a command in app/commands/config.rb
    OUT

    command = "bundle exec teletype add --help"
    out, err, status = Open3.capture3(command)
    expect(out).to eq(output)
    expect(err).to eq('')
    expect(status.exitstatus).to eq(0)
  end
end
