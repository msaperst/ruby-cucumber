# frozen_string_literal: true

# Wrapper class that leverages inheritance to dynamically resolve unknown methods to
# either its wrapped object, or subclasses loaded in the current context.
class Page
  # rubocop:disable Style/OptionalBooleanParameter
  def initialize(driver = nil, wait = nil, load_stuff = false)
    @driver = driver
    @wait = wait
    @mappings = {}
    @all_subclasses = []
    @all_subclasses = subclasses(Page) if load_stuff
  end
  # rubocop:enable Style/OptionalBooleanParameter

  # return all loaded subclasses in current context by checking new constants/symbols
  def subclasses(desired_superclass)
    # ideally may want to also exclude (all) classes from gems in the gemfile for efficiency
    remove = [] # `ruby -e 'require("selenium-webdriver");p Module.constants'`.gsub(/[\[\],:]/, '').split.map(&:to_sym)
    valid_symbols =
      # Ensure the symbol's a class and, if so, an instance is a subclass
      (Module.constants - remove).select do |possible_subclass|
        (Module.const_get(possible_subclass).is_a? Class) &&
          Module.const_get(possible_subclass).new.is_a?(desired_superclass)
      rescue StandardError
        false
      end
    valid_symbols.map { |subclass_symbol| Module.const_get(subclass_symbol) }
  end

  # override MethodMissing's default behavior, see https://www.leighhalliday.com/ruby-metaprogramming-method-missing
  def method_missing(miss, *args, &block)
    return @driver.send(miss, *args, &block) if @driver.respond_to?(miss, true)

    @all_subclasses.each do |subclass|
      return @mappings[miss].send(miss, *args, &block) unless @mappings[miss].nil?

      temp = subclass.new(@driver, @wait)
      next unless temp.respond_to? miss, true # https://stackoverflow.com/a/18918342

      @mappings[miss] = temp
      return temp.send(miss, *args, &block)
    end
    raise "Ambiguous or missing method/symbol: #{miss}"
  end

  def respond_to_missing?(*_args)
    false
  end

  # These methods optionally stand in for certain @driver / @wait operations.
  # Seek is only really useful if you specifcally want an :id

  # passes all elements to `@wait.until { seek('<whatever>')` or `@wait.until { @driver.<whatever>.displayed? }`,
  # depending on if they're a string or symbol (respectively).
  def await(*target)
    target.each do |tgt|
      case tgt
      when Symbol
        @wait.until { method_missing(tgt)&.displayed? }
      when String
        @wait.until { seek(tgt) }
      else
        raise "Await: unknown type or something went wrong for #{tgt}"
      end
    end
  end

  # rubocop:disable Style/OptionalArguments

  # find a cognito-specific form (see `pages/login.rb#element_count`)
  def seek_duped(tag = :id, element_name)
    find_elements(tag, element_name)[element_count]
  end

  # alias for @driver.find_element([:id or (tag)], (element_name))
  def seek(tag = :id, element_name)
    find_element(tag, element_name)
  end
  # rubocop:enable Style/OptionalArguments

  def execute_script(...)
    @driver.execute_script(...)
  end
end
