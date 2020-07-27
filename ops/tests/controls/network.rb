title "delineate.io Platform Network Tests"

gcp_project_id = attribute("gcp_project_id")
gcp_region = attribute("gcp_region")

control "app-network-1.0" do
  impact 1.0
  title "Ensure network is as expected"

  # Make sure the default network has been deleted
  describe google_compute_network(project: gcp_project_id, name: 'default') do
    it { should_not exist }
  end

  # Tests that the network is as expected
  describe google_compute_network(project: gcp_project_id, name: 'app-network') do
    it { should exist }
    its ('auto_create_subnetworks'){ should be false }
    its ('routing_config.routing_mode') { should eq "REGIONAL" }
    its ('subnetworks.count') { should eq 1 }
    its ('subnetworks.first') { should match "app-subnet-" + gcp_region}
  end

end
