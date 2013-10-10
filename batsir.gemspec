# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "batsir"
  s.version = "0.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["J.W. Koelewijn", "Bram de Vries"]
  s.date = "2013-10-10"
  s.description = "Batsir uses so called stages to define operation queues. These operation queus\n consist of several operations that will be executed one after the other. Each stage\n is defined by its name and the queue on which it will listen. Once a message is received\n on the queue, it is dispatched to a worker in a seperate thread that will pass the message\n to each operation in the operation queue.\n Operation queues can have 4 different operations, 1 common operation type, and 3 special\n purpose operations: retrieval operations (which are always executed before all other operations),\n persistence operations (which are always executed after the common operations, but before the\n notification operations) and notification operations (which will always be executed last)\n This makes it possible to create chains of stages to perform tasks that depend on each\n other, but otherwise have a low coupling"
  s.email = "jwkoelewijn@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".travis.yml",
    "CHANGES.md",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "batsir.gemspec",
    "batsir.png",
    "lib/batsir.rb",
    "lib/batsir/acceptors/acceptor.rb",
    "lib/batsir/acceptors/amqp_acceptor.rb",
    "lib/batsir/amqp.rb",
    "lib/batsir/amqp_consumer.rb",
    "lib/batsir/chain.rb",
    "lib/batsir/compiler/stage_worker_compiler.rb",
    "lib/batsir/config.rb",
    "lib/batsir/dsl/conditional_notifier_declaration.rb",
    "lib/batsir/dsl/dsl_mappings.rb",
    "lib/batsir/errors.rb",
    "lib/batsir/filter.rb",
    "lib/batsir/filter_queue.rb",
    "lib/batsir/log.rb",
    "lib/batsir/logger.rb",
    "lib/batsir/logo.rb",
    "lib/batsir/notifiers/amqp_notifier.rb",
    "lib/batsir/notifiers/conditional_notifier.rb",
    "lib/batsir/notifiers/notifier.rb",
    "lib/batsir/registry.rb",
    "lib/batsir/stage.rb",
    "lib/batsir/stage_worker.rb",
    "lib/batsir/strategies/retry_strategy.rb",
    "lib/batsir/strategies/strategy.rb",
    "lib/batsir/transformers/field_transformer.rb",
    "lib/batsir/transformers/json_input_transformer.rb",
    "lib/batsir/transformers/json_output_transformer.rb",
    "lib/batsir/transformers/transformer.rb",
    "lib/batsir/version.rb",
    "spec/batsir/acceptors/acceptor_spec.rb",
    "spec/batsir/acceptors/amqp_acceptor_spec.rb",
    "spec/batsir/acceptors/shared_examples.rb",
    "spec/batsir/amqp_spec.rb",
    "spec/batsir/chain_spec.rb",
    "spec/batsir/config_spec.rb",
    "spec/batsir/dsl/chain_mapping_spec.rb",
    "spec/batsir/dsl/conditional_notifier_mapping_spec.rb",
    "spec/batsir/dsl/stage_mapping_spec.rb",
    "spec/batsir/filter_queue_spec.rb",
    "spec/batsir/filter_spec.rb",
    "spec/batsir/log_spec.rb",
    "spec/batsir/logger_spec.rb",
    "spec/batsir/notifiers/amqp_notifier_spec.rb",
    "spec/batsir/notifiers/conditional_notifier_spec.rb",
    "spec/batsir/notifiers/notifier_spec.rb",
    "spec/batsir/notifiers/shared_examples.rb",
    "spec/batsir/registry_spec.rb",
    "spec/batsir/stage_spec.rb",
    "spec/batsir/stage_worker_spec.rb",
    "spec/batsir/strategies/retry_strategy_spec.rb",
    "spec/batsir/strategies/strategy_spec.rb",
    "spec/batsir/support/bunny_mocks.rb",
    "spec/batsir/support/mock_filters.rb",
    "spec/batsir/transformers/field_transformer_spec.rb",
    "spec/batsir/transformers/json_input_transformer_spec.rb",
    "spec/batsir/transformers/json_output_transformer_spec.rb",
    "spec/batsir/transformers/transformer_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/jwkoelewijn/batsir"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Batsir is an execution platform for stage based operation queue execution"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bundler>, ["> 1.0.0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<rdoc>, [">= 0"])
      s.add_runtime_dependency(%q<blockenspiel>, [">= 0.4.3"])
      s.add_runtime_dependency(%q<celluloid>, ["~> 0.14.1"])
      s.add_runtime_dependency(%q<sidekiq>, [">= 2.5.4"])
      s.add_runtime_dependency(%q<bunny>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<log4r>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["> 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<blockenspiel>, [">= 0.4.3"])
      s.add_dependency(%q<celluloid>, ["~> 0.14.1"])
      s.add_dependency(%q<sidekiq>, [">= 2.5.4"])
      s.add_dependency(%q<bunny>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<log4r>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["> 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<blockenspiel>, [">= 0.4.3"])
    s.add_dependency(%q<celluloid>, ["~> 0.14.1"])
    s.add_dependency(%q<sidekiq>, [">= 2.5.4"])
    s.add_dependency(%q<bunny>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<log4r>, [">= 0"])
  end
end

