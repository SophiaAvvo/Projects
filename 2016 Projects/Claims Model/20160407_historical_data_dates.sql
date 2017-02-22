SELECT COUNT(d.professional_id) ProfCount
 ,MIN(etl_effective_begin_date) min_etl_effective_begin_date
 ,MIN(etl_effective_end_date) min_etl_effective_end_date
 ,MIN(source_system_begin_date) min_source_system_begin_date
 ,MIN(source_system_end_date) min_source_system_end_date
 ,MIN(etl_load_datetime) min_etl_load_datetime
from dm.historical_professional_dimension d
LEFT JOIN dm.date_dim dd
  ON dd.actual_date = d.
--WHERE d.professional_id = 10007
GROUP BY 1
/*WHERE etl_effective_begin_date <> '1900-01-01'
AND source_system_begin_date <> '1900-01-01'
AND source_system_end_date NOT IN ('1899-12-31', '1900-01-01') */
--WHERE d.professional_id =100004
