#!/usr/bin/env rspec

#
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

require_relative "../../spec_helper"
require "y2sap/clients/sequence"

describe Y2Sap::Clients::Sequence do
  subject(:client) { described_class.new }

  describe "#main" do
    before do
      allow(FileUtils).to receive(:mkdir_p)
    end
    it "Start the sequence" do
      expect(client.read).to eq(:next)
    end
  end
end
