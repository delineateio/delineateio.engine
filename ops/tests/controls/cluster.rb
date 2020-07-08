title "delineate.io Infrastructure Tests"

gcp_project_id = attribute("gcp_project_id")

control "app-cluster-1.0" do
  impact 1.0
  title "Ensure application cluster is as expected"
  describe google_container_cluster(project: gcp_project_id, location: 'europe-west2-a', name: 'app-cluster') do
    it { should exist }
  end
end
