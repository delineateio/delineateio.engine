title "delineate.io Platform Cluster Tests"

gcp_project_id = attribute("gcp_project_id")
gcp_zone = attribute("gcp_zone")

control "app-cluster-1.0" do
  impact 1.0
  title "Ensure cluster is as expected"

  # External IP address is available
  describe google_compute_global_address(project: gcp_project_id, name: 'app-cluster-ip') do
    it { should exist }
    its('address_type') { should eq 'EXTERNAL' }
  end

  describe google_container_clusters(project: gcp_project_id, location: gcp_zone) do
    its('count') { should eq 1}
  end

  # Checks the cluster itself
  describe google_container_cluster(project: gcp_project_id, location: gcp_zone, name: 'app-cluster') do
    it { should exist }
    its('status') { should eq 'RUNNING' }
  end

end
