{{
    config(
        materialized='incremental',
        unique_key = 'session_id'
    )
}}

with page_views as (

    select * from {{ ref('page_views') }}

    {% if is_incremental() %}
    where collector_tstamp >= (select max(collector_tstamp) from {{ this }})
    {% endif %}

),

sessions as (

    select
        session_id,
        anonymous_user_id,

        count(*) as page_views,
        sum(approx_time_on_page) as total_time,
        min(page_view_start) as session_start,
        max(collector_tstamp) as collector_tstamp

    from page_views

    group by 1,2

)

select * from sessions
