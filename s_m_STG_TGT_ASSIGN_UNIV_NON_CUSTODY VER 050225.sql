-- all missing landing assignments
with all_missing_ldg_assign as (
	select 
		row_number() over(order by recipient_id) as temp_idx,
		int_id, 
		recipient_id, 
		trunc(to_date(begin_date,'yyyymmdd')) as beg_date,
		case when end_date = 22991231 or end_date is null 
			then to_date('99991231','yyyymmdd') 
		else  to_date(end_date,'yyyymmdd') end as end_date,
		status,
		null pers_id
	from
	mcee_ldg.ldg_mits_mc_assignment asgn
	where 
	not exists 
	(
		select 1
		from mcee_stg.stg_int_edbc_assign_univ ea
		where
		asgn.recipient_id = ea.recipient_id
		and asgn.int_id = ea.ldg_assign_id
	and
	ea.recipient_id in ( '001004740258', '089093580280')
	)
	and
	asgn.recipient_id in ( '001004740258', '089093580280')
),

-- find_pers_id_from_custody has all missing records with or without pers_id(s)
find_pers_id_from_custody as (
	select 
	coalesce_pers_id.temp_idx,
	coalesce_pers_id.int_id,
	coalesce_pers_id.recipient_id,
	coalesce_pers_id.beg_date,
	coalesce_pers_id.end_date,
	coalesce_pers_id.new_pers_id as pers_id,
	case when pers_id is null then 'non_cust' else 'cust' end as source_type
	from
	(
		select 
		all_recs.temp_idx,
		all_recs.int_id,
		all_recs.recipient_id,
		all_recs.beg_date,
		all_recs.end_date,
		all_recs.pers_id,
		case when pers_id is null then
			coalesce(pers_id ,
				max(pers_id) over (partition by recipient_id order by end_date, beg_date rows between unbounded preceding and current row),  
				min(pers_id) over (partition by recipient_id order by end_date, beg_date  rows between current row and unbounded following)  
		) else pers_id end as new_pers_id
		from 
		(
			select 
			ma.*
			from all_missing_ldg_assign ma
			
			union

			select 
			null as temp_idx,
			cust.ldg_assign_int_id,
			cust.recipient_id,
			cust.beg_date,
			cust.end_date,
			cust.status,
			cust.pers_id
			
			from mcee_stg.stg_tgt_assign_univ cust
			where 
			recipient_id in ( '001004740258', '089093580280') and 
			upper(session_name) = 'S_M_LDG_STG_TGT_ASSIGN_UNIV_CUSTODY'
		) all_recs
	) coalesce_pers_id
),

find_pers_id_from_OB as (
	select
	temp_idx,
	int_id,
	recipient_id,
	beg_date,
	end_date,
	case when pers_id is null then
			coalesce(pers_id ,
				max(pers_id) over (partition by recipient_id order by end_date asc, beg_date asc rows between unbounded preceding and current row),  
				min(pers_id) over (partition by recipient_id order by end_date asc, beg_date asc rows between current row and unbounded following)  
		) else pers_id end as pers_id,
	source_type
	from 
	(
		select *
		from 
		find_pers_id_from_custody where pers_id is null
		
		union

		(
		select
		null temp_idx,
		null int_id,
		pi.recipient_id,
		beg_date,
		end_date,
		ob.pers_id,
		'OB' as source_type
		from
		mcee_stg.stg_int_ob_pgm_pers_detl_status ob
		join mcee_stg.stg_int_pers_identity pi on pi.recipient_id = ob.recipient_id and nvl(pi.ob_pers_id, pi.sacwis_pers_id) = ob.pers_id 
		where

		ob.role_code = 'ME' 
		and ob.stat_code = 'AC'
		and pi.MATCH_OB_PERS_ID is not null
		and ob.recipient_id in ( '001004740258', '089093580280')
		)
	) all_recs
),

all_derived_missing_source as (
	select *
	from find_pers_id_from_OB
	where source_type = 'non_cust'

	union

	select *
	from find_pers_id_from_custody ob
	where source_type = 'non_cust'
	and not exists (
		select 1
		from find_pers_id_from_OB fc
		where fc.temp_idx = ob.temp_idx

	)
)



select distinct 
missing.recipient_id,
null as stg_edbc_assign_int_id,
missing.pers_id,

(
   select code_num_identif
   from 
   abms.code_detl cd
   where cd.catgry_id = '5000005'
   and cd.short_decode_name = assgn.start_reason
) as start_reason,

(
   select code_num_identif
   from 
   abms.code_detl cd
   where cd.catgry_id = '5000005'
   and cd.short_decode_name = assgn.stop_reason
) as stop_reason,


(
   select refer_table_1_descr
   from 
   abms.code_detl cd
   where cd.catgry_id = '5000000'
   and cd.short_decode_name = assgn.plan_id
)          as pgm_type,

(
   select code_num_identif
   from 
   abms.code_detl cd
   where cd.catgry_id = '5000000'
   and cd.short_decode_name = assgn.plan_id
) as plan_name_code,
(
   select short_decode_name
   from 
   abms.code_detl cd
   where cd.catgry_id = '5000000'
   and cd.short_decode_name = assgn.plan_id
) as plan_id,

assgn.program,
assgn.begin_date as beg_date,
assgn.end_date as end_date,

case 
when assgn.status = 'H' then 'I' 
when assgn.status is null then 'V'
end as status,
null as source,
null as disenrollment_letter_ind,

case when assgn.status = 'H' then to_date(assgn.dte_last_update,'YYYYMMDD') else null end as historied_on,
'2012565' as created_by,
'2012565' as updated_by,
sysdate as created_on,
sysdate as updated_on,
assgn.int_id

from all_derived_missing_source missing 
join  mcee_ldg.ldg_mits_mc_assignment assgn
on missing.int_id = assgn.int_id


