module Puppet
  newtype(:openldap_entry) do
    @doc = 'Manage openldap directory entries'

    ensurable

    newparam(:dn) do
      desc 'The distinguished name of the entry'
      isnamevar
    end

    newparam(:purge) do
      desc 'Purge unmanaged attributes'
    end

    newparam(:basedn) do
      desc 'The top level of the DIT in which to manage this resource'
    end

    newproperty(:attributes, :array_matching => :all) do
      desc 'The attributes of the entry'
      def should_to_s(currentvalue)
        currentvalue
      end
    end
  end
end
