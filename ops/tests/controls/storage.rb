title "delineate.io Platform Storage Tests"

gcp_project_id = attribute("gcp_project_id")
gcp_region = attribute("gcp_region").upcase

control "app-storage-1.0" do
  impact 1.0
  title "Ensure storage is as expected"

  # Tests all buckets have the expected items
  describe google_storage_buckets(project: gcp_project_id) do
    its('count') { should eq 3 }
  end

  describe google_storage_bucket(name: gcp_project_id + '-tf') do
    it { should exist }
    its('location') { should eq gcp_region }
  end

  describe google_storage_bucket(name: gcp_project_id + '-deployments') do
    it { should exist }
    its('location') { should eq gcp_region }
    its('versioning.enabled') { should eq true }
  end

end
