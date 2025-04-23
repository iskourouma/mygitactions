select * from cmx_ors.c_bo_client_index_xref
where pkey_src_object like '%12606086%'
union
select * from cmx_ors.c_bo_client_index_xref
where pkey_src_object like '%12173333%';

select * from cmx_ors.c_bo_client_index
where rowid_object in
('42431294      ','43745769      ');

select * from cmx_ors.c_bo_client_index_xref
where rowid_object in
('42431294      ','43745769      ');

select * from cmx_ors.c_bo_alt_id
where alt_id_value = '910002199136';

select * from cmx_ors.C_repos_system;

select * from cmx_ors.c_bo_client_index
WHERE ROWID_OBJECT = '42431294      ';
select * from cmx_ors.c_bo_client_index_XREF
WHERE ROWID_OBJECT = '42431294      ';

SELECT * FROM cmx_ors.c_ldg_client_index;


select * from cmx_ors.c_bo_client_index
where last_update_date > '10-Jan-2025'
and  lower(updated_by) = 'batchuserx2';

select * from cmx_ors.c_bo_client_index
WHERE ROWID_OBJECT = '42976861      ';
select * from cmx_ors.c_bo_client_index_XREF
WHERE ROWID_OBJECT = '42976861      ';


select a.ssn, b.ssn , 
a.ROWID_OBJECT , b.ROWID_OBJECT
from cmx_ors.c_bo_client_index a 
join cmx_ors.c_bo_client_index_xref b
on a.ROWID_OBJECT = b.ROWID_OBJECT
and (a.updated_by) = (b.updated_by)
where
a.last_update_date > '10-Jan-2025'
and  lower(a.updated_by) = 'batchuserx2'
and  lower(b.updated_by) = 'batchuserx2'
and a.ssn <>  b.ssn ;




select a.ssn, b.ssn , 
a.ROWID_OBJECT , b.ROWID_OBJECT, a.*
from cmx_ors.c_bo_client_index@uatx1inf02.ea.ohio.gov a 
join cmx_ors.c_bo_client_index_xref@uatx1inf02.ea.ohio.gov  b
on a.ROWID_OBJECT = b.ROWID_OBJECT
and (a.updated_by) = (b.updated_by)
where
a.last_update_date > '01-Feb-2025'
and  lower(a.updated_by) = 'vijayk'
and  lower(b.updated_by) = 'vijayk'
and a.ssn <>  b.ssn ;


select * from cmx_ors.c_bo_client_index@uatx1inf02.ea.ohio.gov 
WHERE ROWID_OBJECT = '4460086       ';
select * from cmx_ors.c_bo_client_index_XREF@uatx1inf02.ea.ohio.gov 
WHERE ROWID_OBJECT = '4460086       ';



SELECT * FROM cmx_ors.c_ldg_client_index@uatx1inf02.ea.ohio.gov;








