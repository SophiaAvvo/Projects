SELECT professional_id
  ,MIN(license_date) FirstLicenseDate
  ,MAX(license_date) LastLicenseDate
  ,COUNT(id) license_count
FROM src.barrister_license bl
GROUP BY professional_id
