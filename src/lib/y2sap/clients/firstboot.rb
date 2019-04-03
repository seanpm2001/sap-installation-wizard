# encoding: utf-8

# Copyright (c) [2018] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.
#
require "yast"
require "y2sap/partitioning/product_partitioning"
include Yast

module Y2Sap
  # Modul which will be started after the installation of the system
  class FirstbootInstSapClient < Client
    include Y2Sap::ProductPartitioning
    include Yast::Logger
   
    def main
      Yast.import "UI"
      Yast.import "Wizard"
      Yast.import "Package"
      Yast.import "Popup"

      # MAIN

      textdomain "sap-installation-wizard"

      @contents  = nil
      @help_text = ""
      @close_me   = false
      create_dialog
      ui_loop
    end

  private
    def create_dialog
      if !Wizard.IsWizardDialog
        Wizard.CreateDialog
        @close_me = true
      end

      # Check if hostname -f is set
      @out = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), "hostname -f")
      )
      @hostname = Ops.get_string(@out, "stdout", "")
      if @hostname == ""
        if Popup.AnyQuestion(
             _("The fully qualified hostname (FQHN) could not be detected."),
             _("Do you want to return to network setup or abort the SAP product installation and start the installed system?"),
             _("Return to Network Setup"),
             _("Abort"),
             :focus_yes
          )
          return :back
        else
          return :next
         end
      end
      @caption = _("Product Installation Mode")
      @help    = _("The standard installation of the Operating System has settled.") + "<br>" +
                 _("Now you can start the SAP Product Installation")
      @content = RadioButtonGroup(
        Id(:rb),
        VBox(
          Left(
            RadioButton(
              Id("sap_install"),
              "&Create SAP file systems and start SAP product installation.",
              true
            )
          ),
          Left(
            RadioButton(
              Id("hana_partitioning"),
              "Only create &SAP HANA file systems, do not install SAP products now.",
              false
            )
          ),
          Left(
            RadioButton(
              Id("none"),
              "&Finish wizard and proceed to OS login.",
              false
            )
          )
        )
      )
      Wizard.SetDesktopIcon("sap-installation-wizard")
      Wizard.SetContents(
        @caption,
        @content,
        @help,
        true,
        true
      )
    end

    def ui_loop
      ret = nil
      until ret == :next || ret == :back
        ret = Wizard.UserInput
        log.info("ret #{ret}")
        case ret
        when :abort
          break if Popup.ConfirmAbort(:incomplete)
        when :help
          Wizard.ShowHelp(@help)
        when :next
          install = Convert.to_string(UI.QueryWidget(Id(:rb), :CurrentButton))
          case install
          when "sap_install"
            WFM.CallFunction("sap_installation_wizard", [])
            ret = :next
          when "hana_partitioning"
            hana_partitioning
            ret = :next
          end
          SCR.Execute(path(".target.bash"), "rm -rf /tmp/may_*")
          SCR.Execute(path(".target.bash"), "rm -rf /tmp/ay_*")
          SCR.Execute(path(".target.bash"), "rm -rf /tmp/mnt1")
          SCR.Execute(path(".target.bash"), "rm -rf /tmp/current_media_path")
          SCR.Execute(path(".target.bash"), "rm -rf /dev/shm/InstMaster_SWPM/")
          Package.DoRemove(["sap-installation-start"])
        end
      end
      Wizard.CloseDialog() if @close_me
      return ret
    end
  end
end
