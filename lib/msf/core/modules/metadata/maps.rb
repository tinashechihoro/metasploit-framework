#
# Core service class that provides storage of module metadata as well as operations on the metadata.
# Note that operations on this metadata are included as separate modules.
#
module Msf::Modules::Metadata::Maps

  @mrefs  = {}
  @mports = {}
  @mservs = {}


  def all_remote_exploit_maps

    return @mrefs, @mports, @mservs if @mrefs && !@mrefs.empty?

    mrefs  = {}
    mports = {}
    mservs = {}

    get_metadata.each do |exploit|
      next unless exploit.type == "exploit" && exploit.is_server
      fullname = exploit.full_name
      exploit.references.each do |reference|
        next if reference =~ /^URL/
        ref = reference
        ref.upcase!

        mrefs[ref]           ||= {}
        mrefs[ref][fullname] = exploit
      end

      if exploit.rport
        rport                        = exploit.rport
        mports[rport.to_i]           ||= {}
        mports[rport.to_i][fullname] = exploit
      end

      unless exploit.autofilter_ports.nil? || exploit.autofilter_ports.empty?
        exploit.autofilter_ports.each do |rport|
          next unless port_allowed?(rport)
          mports[rport.to_i]           ||= {}
          mports[rport.to_i][fullname] = exploit
        end
      end

      unless exploit.autofilter_services.nil? || exploit.autofilter_services.empty?
        exploit.autofilter_services.each do |serv|
          mservs[serv]           ||= {}
          mservs[serv][fullname] = exploit
        end
      end

    end
    @mrefs  = mrefs
    @mports = mports
    @mservs = mservs

    return @mrefs, @mports, @mservs
  end

  private

  def clear_maps
    @mrefs = nil
    @mports = nil
    @mservs = nil
  end

end
