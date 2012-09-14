require 'tempfile'

Puppet::Type.type(:openldap_entry).provide :ldapmodify do
  desc 'Provide openldap_entry using ldapmodify'
  confine :operatingsystem => [:debian, :ubuntu, :centos, :rhel]
  defaultfor :operatingsystem => [:debian, :ubuntu, :centos, :rhel]
  optional_commands :ldapsearch => 'ldapsearch'
  optional_commands :ldapmodify => 'ldapmodify'

  def rdn
    @rdn || @rdn = @resource[:dn].gsub(/,#{@resource[:basedn]}$/, '')
  end

  def create
  end

  def delete
  end

  def exists?
    ldapsearch :basedn => @resource[:dn], :scope => :base, :filter => 'dn'
  end

  def attributes
    return @attributes if @attributes
    attrs = ldapsearch(:basedn => @resource[:dn], :scope => :base)
    if attrs.count > 1
      Puppet.fail "More than one dn returned for #{@resource[:dn]}"
    end
    @attributes = attrs.first.select { |attr| !(attr =~ /^dn: /) }
  end

  def attributes=(should_attributes)
    should_attributes = [should_attributes].flatten.compact
    missing = should_attributes - attributes
    extras = attributes - should_attributes

    ldif_header = ["dn: #{@resource[:dn]}", 'changetype: modify']
    ldif = Array.new
    if @resource[:purge]
      extras.each { |entry| ldif << "delete: #{attribute_name(entry)}" }
    end
    missing.each { |entry| ldif << "add: #{attribute_name(entry)}\n#{entry}" }
    ldif = [ldif_header, ldif.join("\n-\n")].join("\n")
    ldapmodify(ldif)
  end

  def attribute_name(attribute)
    attribute.match(/(\w+): /)[1]
  end

  def ldapsearch(options = {})
    cmd = [command(:ldapsearch), '-LLL', '-H', 'ldapi:///', '-Y', 'EXTERNAL']
    cmd << '-s' << options[:scope].to_s if options[:scope]
    cmd << '-b' << options[:basedn].to_s if options[:basedn]
    cmd << options[:filter].to_s if options[:filter]
    cmd << options[:attributes].to_s if options[:attributes]
    output = execute cmd, :combine => false
    return nil if output.nil? or output.empty?
    output.split("\n\n").map { |e| e.split("\n") }
  end

  def ldapmodify(ldif)
    cmd = [command(:ldapmodify), '-Y', 'EXTERNAL', '-H', 'ldapi:///']
    Tempfile.new('puppet_ldif') do |tempfile|
      cmd << '-f' << tempfile.path
      execute cmd, :combine => false
    end
  end

end
