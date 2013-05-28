
module Livecd
  VM_PREFIX = 'livecd-'

  def list_vms
    `vboxmanage list vms`.
       split("\n").
       # match each line to the regex we expect
       map{|x| /^"([^"]+)" {[^}]*}/.match(x)}.
       # remove nil's
       compact.
       # get the first match
       map{|x| x[1]}.
       # find all those that have the prefix
       find_all{|x| x.start_with? VM_PREFIX }
  end

  def exists_vm( name )
    list_vms.include? name
  end

  def stop_vm( name )
    # if it exists:
    puts "stopping vm #{name}"
    if exists_vm(name)
      `vboxmanage controlvm #{name} poweroff`
      `vboxmanage unregistervm #{name} --delete`
    end
  end

  def stop_all_vms
    list_vms.each{|vm| stop_vm(vm)}
  end

  def start_vm( name, iso, headless = false )
    # create the new vm
    `vboxmanage createvm --name #{name} --register`
    `vboxmanage modifyvm #{name} --ostype "Other"`
    `vboxmanage storagectl #{name} --name "IDE Controller" --add ide --bootable on`
    `vboxmanage storageattach #{name} --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium "#{iso}"`
    `vboxmanage modifyvm #{name} --nic1 nat`
    `vboxmanage modifyvm #{name} --nic2 hostonly --hostonlyadapter2 vboxnet0`
    hl = (headless) ? '--type headless' : ''
    `vboxmanage startvm #{name} #{hl}`
  end

  def find_name_for( iso )
    base = File::basename iso, '.iso'
    allowed_chars = /[a-z0-9_+-]+/i
    name = VM_PREFIX + base.scan(allowed_chars).join('')

    vms = list_vms
    return name if not vms.include? name

    # so, name already exists, find an alternative
    # collect the existing digits we have already assigned first:
    digits = vms.
      # whatever fits our naming pattern
      find_all{|v| v.start_with? name}.
      # remove the prefix name
      map{|v| v.sub(name, '')}.
      # try to match the postfix to -[0-9]+ digits
      map{|v| v.match /^-([0-9]+)$/}.
      # remove all nonmatching
      compact.
      # get the digits
      map{|v| v[1].to_i}.sort

    # search for the first free digit
    i = 1
    while digits.include? i
      i += 1
    end
    "#{name}-#{i}"
  end

  def run_iso( iso, opts )
    name = find_name_for iso
    puts "starting vm #{name} (#{iso})"
    start_vm name, iso, opts[:headless]
  end
end
