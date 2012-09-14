class openldap::params {

  case $::osfamily {
    default: { fail("osfamily \"$::osfamily\" not supported by openldap") }
    'RedHat': {
      $confdir = '/etc/openldap/slapd.d'
      $schemadir = '/etc/openldap/schema'
      $server_service = 'ldap'
      $server_package = [
        'openldap',
        'openldap-servers',
      ]
      $common_package = [ ]
    }
    'Debian': {
      $confdir = '/etc/ldap/slapd.d'
      $schemadir = '/etc/ldap/schema'
      $server_service = 'slapd'
      $server_package = [
        'slapd',
      ]
      $common_package = 'ldap-utils'
    }
  }

  $base_dn_prelim = regsubst($::domain, '\.', ',dc=', 'G')
  $base_dn_default = regsubst($base_dn_prelim, '^', 'dc=')

}
