---create tables for years 2016-2020 for DC
--and clean
--REMOVE  NULLS FROM NEEDED COLUMNS 
--- REMOVE ANY STATUSES WITH  THE WORD DUPLICATE 
--removing any test or autamated calls
WITH all_dc_clean_base AS (
select * from(
    SELECT * FROM public.dc_311_2020
    UNION
    SELECT * FROM public.dc_311_2019
    UNION
    SELECT * FROM public.dc_311_2018
    UNION
    SELECT * FROM public.dc_311_2017
    UNION
    SELECT * FROM public.dc_311_2016)
	as combined
WHERE request_id IS NOT NULL
    AND created_date IS NOT NULL
    AND priority IS NOT NULL
    AND status NOT ILIKE '%DUPLICATE%'
    AND category NOT ILIKE '%Test%'
    AND category NOT ILIKE '%Automation%'
    AND (requesttype IS NULL OR requesttype NOT ILIKE '%Test%')
    AND (requesttype IS NULL OR requesttype NOT ILIKE '%Automation%')
)

/*WHERE request_id IS NOT NULL
  AND created_date IS NOT NULL
  AND priority IS NOT NULL
  AND status NOT ILIKE '%DUPLICATE%'
  AND category NOT ILIKE '%Test%'
AND category NOT ILIKE '%Automation%'
AND requesttype NOT ILIKE '%Test%'
AND requesttype NOT ILIKE '%Automation%'),*/
,cleaned_base AS (SELECT *,
  -- Fill missing requesttype using category
  --create cleaned_category
        CASE
            WHEN requesttype IS NULL THEN INITCAP(TRIM(category))
            ELSE requesttype
        END AS filled_requesttype,
		INITCAP(TRIM(category)) AS cleaned_category,

-- standersise status into 4 categories as new status 
	CASE 
    WHEN status ILIKE 'open' 
      OR status ILIKE 'dispute (open)' THEN 'Open'
	  
    WHEN status ILIKE 'in progress'
      OR status ILIKE 'in-progress'
      OR status ILIKE 'dispute' THEN 'In Progress'

    WHEN status ILIKE 'closed'
      OR status ILIKE 'close'
      OR status ILIKE 'dispute (closed)'
      OR status ILIKE 'closed (transferred)' THEN 'Closed'

    WHEN status ILIKE '%incomplete information%'
      OR status ILIKE 'voided' THEN 'Incomplete Information'
    
    ELSE status
END AS new_status,
-- -- Clean requesttype using filled_requesttype
CASE 
    WHEN (CASE WHEN requesttype IS NULL THEN INITCAP(TRIM(category)) ELSE requesttype END) = 'Urban Forrestry' THEN 'Urban Forestry'
    WHEN (CASE WHEN requesttype IS NULL THEN INITCAP(TRIM(category)) ELSE requesttype END) ILIKE '%Admistration%' THEN 'Administration'
    WHEN (CASE WHEN requesttype IS NULL THEN INITCAP(TRIM(category)) ELSE requesttype END) = 'Traffic Signal Maintanence' THEN 'Traffic Signal Maintenance'
    ELSE INITCAP(TRIM(CASE WHEN requesttype IS NULL THEN category ELSE requesttype END))
END AS cleaned_requesttype,
  CASE
  WHEN INITCAP(TRIM(category)) ILIKE '%covid%' OR INITCAP(TRIM(category)) ILIKE '%corona%' OR INITCAP(TRIM(category)) ILIKE '%virus%' OR INITCAP(TRIM(category)) ILIKE '%quarantine%' THEN 'Public Health Emergency'
  WHEN INITCAP(TRIM(category)) ILIKE '%emergency%' AND INITCAP(TRIM(category)) ILIKE '%tree%' THEN 'Natural Disaster Response'
  WHEN INITCAP(TRIM(category)) ILIKE '%emergency%' AND INITCAP(TRIM(category)) ILIKE '%transport%' THEN 'Natural Disaster Response'
  WHEN INITCAP(TRIM(category)) ILIKE '%flood%' OR INITCAP(TRIM(category)) ILIKE '%flooding%' THEN 'Natural Disaster Response'
  WHEN INITCAP(TRIM(category)) ILIKE '%power outage%' OR INITCAP(TRIM(category)) ILIKE '%wire down%' THEN 'Natural Disaster Response'
  WHEN INITCAP(TRIM(category)) ILIKE '%dmv%' OR INITCAP(TRIM(category)) ILIKE '%vehicle registration%' OR INITCAP(TRIM(category)) ILIKE '%vehicle title%' OR INITCAP(TRIM(category)) ILIKE '%drivers license%' OR INITCAP(TRIM(category)) ILIKE '%ticket%' THEN 'DMV & Vehicle Paperwork'
  WHEN INITCAP(TRIM(category)) ILIKE '%abandoned vehicle%' OR INITCAP(TRIM(category)) ILIKE '%junk motor vehicle%' THEN 'Vehicle Abandonment'
  WHEN INITCAP(TRIM(category)) ILIKE '%trash%' OR INITCAP(TRIM(category)) ILIKE '%bulk%' OR INITCAP(TRIM(category)) ILIKE '%container%' OR INITCAP(TRIM(category)) ILIKE '%supercan%' OR INITCAP(TRIM(category)) ILIKE '%litter%' THEN 'Trash & Waste'
  WHEN INITCAP(TRIM(category)) ILIKE '%tree%' OR INITCAP(TRIM(category)) ILIKE '%forestry%' THEN 'Tree Services'
  WHEN INITCAP(TRIM(category)) ILIKE '%snow%' OR INITCAP(TRIM(category)) ILIKE '%leaf%' OR INITCAP(TRIM(category)) ILIKE '%christmas%' THEN 'Seasonal Services'
  WHEN INITCAP(TRIM(category)) ILIKE '%rodent%' OR INITCAP(TRIM(category)) ILIKE '%rat%' OR INITCAP(TRIM(category)) ILIKE '%insect%' OR INITCAP(TRIM(category)) ILIKE '%bed bug%' THEN 'Pest Control'
  WHEN INITCAP(TRIM(category)) ILIKE '%pothole%' OR INITCAP(TRIM(category)) ILIKE '%roadway%' OR INITCAP(TRIM(category)) ILIKE '%street%' OR INITCAP(TRIM(category)) ILIKE '%sidewalk%' OR INITCAP(TRIM(category)) ILIKE '%curb%' OR INITCAP(TRIM(category)) ILIKE '%gutter%' THEN 'Street & Sidewalk Repair'
  WHEN INITCAP(TRIM(category)) ILIKE '%parking%' OR INITCAP(TRIM(category)) ILIKE '%meter%' OR INITCAP(TRIM(category)) ILIKE '%resident parking%' THEN 'Parking Issues'
  WHEN INITCAP(TRIM(category)) ILIKE '%doee%' OR INITCAP(TRIM(category)) ILIKE '%foam%' OR INITCAP(TRIM(category)) ILIKE '%bag law%' OR INITCAP(TRIM(category)) ILIKE '%environment%' THEN 'Environmental Concerns'
  WHEN INITCAP(TRIM(category)) ILIKE '%issue%' OR INITCAP(TRIM(category)) ILIKE '%tru report%' OR INITCAP(TRIM(category)) ILIKE '%311force%' THEN 'General Issues'
  ELSE 'Other'
END AS final_category
    FROM all_dc_clean_base),
	final_base AS(
--check all responsible agencies
--Standardize and fill responsibleagency
-- recatogrise genral ouc 
SELECT *,
    CASE 
      WHEN responsibleagency IS NULL AND (category ILIKE '%Trash%' OR requesttype ILIKE '%Trash%') THEN 'DPW'
      WHEN responsibleagency IS NULL AND (category ILIKE '%Snow%' OR requesttype ILIKE '%Snow%') THEN 'DPW'
      WHEN responsibleagency IS NULL AND (category ILIKE '%Tree%' OR requesttype ILIKE '%Tree%') THEN 'DDOT'
      WHEN responsibleagency IS NULL AND (category ILIKE '%DMV%' OR requesttype ILIKE '%DMV%') THEN 'DMV'
      WHEN responsibleagency ILIKE '%Serve DC%' AND category ILIKE '%Trash%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%Serve DC%' AND category ILIKE '%Tree%' THEN 'DDOT'
      WHEN responsibleagency ILIKE '%Serve DC%' THEN 'OUC'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Flood%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Transportation%' THEN 'DDOT'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%DMV%' THEN 'DMV'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Trees%' THEN 'DDOT'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Heating%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Cooling%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Power Outage%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Wires Down%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Pet Waste%' THEN 'DPW'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Hypothermia%' THEN 'DC-ICH'
      WHEN responsibleagency ILIKE '%OUC%' AND category ILIKE '%Senior Assistance%' THEN 'DDS'
      WHEN responsibleagency ILIKE '%OUC%' THEN 'OUC'
      ELSE UPPER(TRIM(responsibleagency))
    END AS cleaned_agency
  FROM cleaned_base
),
grouped_base AS (
  SELECT *,
    CASE
      WHEN cleaned_agency IN ('DPW', 'DOEE', 'DGS') THEN 'Public Works & Environment'
      WHEN cleaned_agency IN ('DDOT', 'DMV', 'DFHV', 'ORM') THEN 'Transportation & Parking'
      WHEN cleaned_agency IN ('DOH', 'DDS', 'DC-ICH') THEN 'Health & Human Services'
      WHEN cleaned_agency = 'FEMS' THEN 'Emergency & Fire Services'
      WHEN cleaned_agency = 'DCRA' THEN 'Regulatory & Legal'
	  WHEN cleaned_agency = 'OUC' AND cleaned_requesttype ILIKE '%covid%' THEN 'Health & Human Services'
      WHEN cleaned_agency = 'OUC' THEN 'Unspecified'
      ELSE 'Other'
    END AS agency_group
  FROM final_base)
/* for first chart SELECT
  agency_group,
  cleaned_agency,
  COUNT(*) AS total_requests
FROM grouped_base
GROUP BY agency_group, cleaned_agency
ORDER BY SUM(COUNT(*)) OVER (PARTITION BY agency_group) DESC, total_requests DESC;*/
/*SELECT
  DATE_TRUNC('month', created_date) AS year_month,
  agency_group,
  COUNT(*) AS total_requests
FROM grouped_base
WHERE agency_group IN (
  'Public Works & Environment',
  'Transportation & Parking',
  'Health & Human Services'
)
GROUP BY year_month, agency_group
ORDER BY agency_group, year_month;
*/
/*SELECT *
FROM grouped_base
WHERE requesttype ILIKE '%covid%'
   OR requesttype ILIKE '%coronavirus%'
   OR requesttype ILIKE '%quarantine%'
   OR cleaned_requesttype ILIKE '%covid%'
   OR cleaned_requesttype ILIKE '%coronavirus%'
   OR cleaned_requesttype ILIKE '%quarantine%';*/
SELECT 
  DATE_TRUNC('month', created_date) AS month_year,
  CASE
    -- Vehicle & Parking Issues
    WHEN cleaned_requesttype ILIKE '%dmv%' 
      OR cleaned_requesttype ILIKE '%ticket%' 
      OR cleaned_requesttype ILIKE '%abandoned vehicle%' 
      OR cleaned_requesttype ILIKE '%parking%' 
      OR cleaned_requesttype ILIKE '%citation%' 
      OR cleaned_requesttype ILIKE '%rosa%' 
      THEN 'vehicle_parking_issues'

    -- Traffic & Transportation
    WHEN cleaned_requesttype ILIKE '%traffic%' 
      OR cleaned_requesttype ILIKE '%signal%' 
      OR cleaned_requesttype ILIKE '%streetcar%' 
      OR cleaned_requesttype ILIKE '%school crossing%' 
      OR cleaned_requesttype ILIKE '%school transit%' 
      OR cleaned_requesttype ILIKE '%safe routes%' 
      OR cleaned_requesttype ILIKE '%bus%' 
      OR cleaned_requesttype ILIKE '%bicycle%' 
      THEN 'traffic_transportation'

    -- Street & Infrastructure Repair
    WHEN cleaned_requesttype ILIKE '%repair%' 
      OR cleaned_requesttype ILIKE '%roadway%' 
      OR cleaned_requesttype ILIKE '%sidewalk%' 
      OR cleaned_requesttype ILIKE '%alley%' 
      OR cleaned_requesttype ILIKE '%sign%' 
      OR cleaned_requesttype ILIKE '%marking%' 
      OR cleaned_requesttype ILIKE '%utility%' 
      OR cleaned_requesttype ILIKE '%streetlight%' 
      THEN 'street_infrastructure_repair'

    -- Snow & Seasonal Services
    WHEN cleaned_requesttype ILIKE '%snow%' 
      OR cleaned_requesttype ILIKE '%ice%' 
      OR cleaned_requesttype ILIKE '%shoveling%' 
      OR cleaned_requesttype ILIKE '%christmas%' 
      OR cleaned_requesttype ILIKE '%leaf%' 
      THEN 'snow_seasonal_services'

    -- Trash & Sanitation
    WHEN cleaned_requesttype ILIKE '%trash%' 
      OR cleaned_requesttype ILIKE '%supercan%' 
      OR cleaned_requesttype ILIKE '%bulk%' 
      OR cleaned_requesttype ILIKE '%dumping%' 
      OR cleaned_requesttype ILIKE '%street cleaning%' 
      OR cleaned_requesttype ILIKE '%sanitation%' 
      OR cleaned_requesttype ILIKE '%container%' 
      OR cleaned_requesttype ILIKE '%recycling%' 
      THEN 'trash_sanitation'

    -- Tree & Yard Services
    WHEN cleaned_requesttype ILIKE '%tree%' 
      OR cleaned_requesttype ILIKE '%yard%' 
      OR cleaned_requesttype ILIKE '%vacant lot%' 
      THEN 'tree_yard_services'

    -- Pest & Animal Control
    WHEN cleaned_requesttype ILIKE '%rodent%' 
      OR cleaned_requesttype ILIKE '%insect%' 
      OR cleaned_requesttype ILIKE '%bed bug%' 
      OR cleaned_requesttype ILIKE '%dead animal%' 
      OR cleaned_requesttype ILIKE '%pet waste%' 
      THEN 'pest_animal_control'

    -- School & Youth Programs
    WHEN cleaned_requesttype ILIKE '%school%' 
      OR cleaned_requesttype ILIKE '%recycling - school%' 
      OR cleaned_requesttype ILIKE '%safe routes%' 
      THEN 'school_youth_programs'

    -- Environmental Concerns
    WHEN cleaned_requesttype ILIKE '%doee%' 
      OR cleaned_requesttype ILIKE '%foam%' 
      OR cleaned_requesttype ILIKE '%bag law%' 
      OR cleaned_requesttype ILIKE '%odor%' 
      OR cleaned_requesttype ILIKE '%electronics%' 
      OR cleaned_requesttype ILIKE '%shut the door%' 
      THEN 'environmental_concerns'

    -- COVID & Emergency Health
    WHEN cleaned_requesttype ILIKE '%covid%' 
      OR cleaned_requesttype ILIKE '%quarantine%' 
      OR cleaned_requesttype ILIKE '%emergency%' 
      OR cleaned_requesttype ILIKE '%power outage%' 
      OR cleaned_requesttype ILIKE '%wire%' 
      OR cleaned_requesttype ILIKE '%heating%' 
      OR cleaned_requesttype ILIKE '%cooling%' 
      OR cleaned_requesttype ILIKE '%senior%' 
      OR cleaned_requesttype ILIKE '%hypothermia%' 
      OR cleaned_requesttype ILIKE '%dds%' 
      THEN 'covid_emergency_health'

    -- Administrative & Other
    ELSE 'administrative_other'
  END AS category_group,
  COUNT(*) AS request_count
FROM grouped_base
WHERE agency_group IN (
  'Public Works & Environment',
  'Transportation & Parking',
  'Health & Human Services'
)
GROUP BY month_year, category_group
ORDER BY month_year, category_group;
