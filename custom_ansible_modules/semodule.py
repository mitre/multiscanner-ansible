#!/usr/bin/python

DOCUMENTATION = '''
---
module: semodule
short_description: Compiles and installs SE policy from TE file
description:
     - Manages SELinux file context mapping definitions
     - Similar to the C(semanage fcontext) command
version_added: "N/A"
options:
  te_file:
    description:
      - Type Enforcement file holding the rules to go into the policy.
    required: true
    default: null
    aliases: ['tefile']
  module_name:
    description:
      - Name of the policy module (defined on line 1 of TE file).
    required: true
    default: null
    aliases: ['modname']
  module_version:
    description:
      - Version of the policy module (defined on line 1 of TE file).
    required: true
    default: null
    aliases: ['modver']
notes:
   - The changes are persistent across reboots
requirements: [ 'policycoreutils-python' ]
author: jfeild1337
'''

EXAMPLES = '''
# Create and install policy from rules in 'mycustomrules.te'
- semodule:
    te_file: /tmp/mycustomrules.te
    module_name: mycustomrules
    module_version: 1.0
'''

RETURN = '''
# Default return values
'''

from ansible.module_utils.pycompat24 import get_exception
from ansible.module_utils.basic import *
from ansible.module_utils._text import to_native
import re

# make sure policycoreutils-python is installed
try:
    import seobject
    POLICY_COREUTILS_INSTALLED=True
except ImportError:
    POLICY_COREUTILS_INSTALLED=False

def is_policy_present(module, module_name, module_version):
    """
    Checks if the specified policy module is already installed.
    Returns True if it is, and False if not
    """
    try:
        check_policy = 'semodule -l'
        rc, out, err = module.run_command(' '.join([check_policy]))
        if rc != 0:
            module.fail_json(msg='error checking status of policy module {}; command (rc={}): {}'.format(module_name, rc, out or err))

        # see if module is installed and at correct version
        regexp = "(%s)(\s)*(%s)" % (module_name, module_version)
        match_res = re.search(regexp, out)

        if match_res:
            return True
        else:
            return False
        print('MODULE INSTALLED? ' + match_res)
    except Exception:
        e = get_exception()
        module.fail_json(msg="%s: %s\n" % (e.__class__.__name__, to_native(e)))

def compile_and_install_policy(module, te_file, module_name, module_version, result):
    """
    Compiles the specified TE file into a policy module and installs it
    """
    changed = False
    prepared_diff = ''

    policy_already_installed = is_policy_present(module, module_name, module_version)
    if not policy_already_installed:
        # commands
        mod_file = '%s.mod' % module_name
        policy_file = '%s.pp' % module_name
        cmd_create_mod_file = 'checkmodule -M -m -o %s %s' % (mod_file, te_file)
        cmd_compile_policy = 'semodule_package -m %s -o %s' % (mod_file, policy_file)
        cmd_install_module = 'semodule -i %s' % policy_file

        try:
            # create mod file
            rc, out, err = module.run_command(' '.join([cmd_create_mod_file]))
            if rc != 0:
                module.fail_json(
                    msg='error creating mod file %s: %s' % (mod_file, out or err))
            # compile policy
            rc, out, err = module.run_command(' '.join([cmd_compile_policy]))
            if rc != 0:
                module.fail_json(
                    msg='error compiling policy %s: %s' % (policy_file, out or err))
            # install policy
            rc, out, err = module.run_command(' '.join([cmd_install_module]))
            if rc != 0:
                module.fail_json(
                    msg='error installing policy %s: %s' % (policy_file, out or err))

            changed = True
            if module._diff:
                prepared_diff += '# Added SELinux Policy\n'
                prepared_diff += '+%s      %s\n' % (module_name, module_version)

        except Exception:
            e = get_exception()
            module.fail_json(msg="%s: %s\n" % (e.__class__.__name__, to_native(e)))

    if module._diff and prepared_diff:
        result['diff'] = dict(prepared=prepared_diff)

    module.exit_json(changed=changed, **result)

def check_if_system_state_would_be_changed(module, module_name, module_version):
    would_be_changed = not is_policy_present(module, module_name, module_version)

def main():
    module = AnsibleModule(
        argument_spec=dict(
            te_file=dict(required=True, aliases=['tefile']),
            module_name=dict(required=True, aliases=['modname']),
            module_version=dict(required=True, aliases=['modver']),
        ),
        supports_check_mode=True,
    )

    if not POLICY_COREUTILS_INSTALLED:
        module.fail_json(msg="This module requires policycoreutils-python")

    te_file = module.params['te_file']
    module_name = module.params['module_name']
    module_version = module.params['module_version']

    if module.check_mode:
        # Check if any changes would be made but don't actually make those changes
        module.exit_json(changed=check_if_system_state_would_be_changed(module, module_name, module_version))

    result = dict(te_file=te_file, module_name=module_name, module_version=module_version)
    compile_and_install_policy(module, te_file, module_name, module_version, result)

if __name__ == '__main__':
    main()