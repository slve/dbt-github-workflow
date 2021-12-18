{{ config(
  materialized="table",
  post_hook=[
    "
      INSERT INTO {{ this }} (field1) VALUES(4),(5),(6)
    ",
    "
      DELETE FROM {{ this }} WHERE field1=5
    "
  ]
) }}
-- select * from {{ this }}
-- where field1 like {% raw %}'[{%'{% endraw %}
-- union all
select 2 as field1
