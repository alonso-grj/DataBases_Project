create table if not exists institutes
(
    institute_id   int auto_increment
        primary key,
    institute_name varchar(100) not null,
    constraint institute_name
        unique (institute_name)
);

create table if not exists projects
(
    project_id         int auto_increment
        primary key,
    project_name       varchar(100) not null,
    manager_first_name varchar(50)  not null,
    manager_last_name  varchar(50)  not null,
    institute_id       int          not null,
    start_date         date         not null,
    end_date           date         not null,
    constraint project_name
        unique (project_name),
    constraint projects_ibfk_1
        foreign key (institute_id) references institutes (institute_id),
    check (`end_date` >= `start_date`)
);

create table if not exists analysis_fields
(
    field_id   int auto_increment
        primary key,
    project_id int         not null,
    field_name varchar(50) not null,
    constraint project_id
        unique (project_id, field_name),
    constraint analysis_fields_ibfk_1
        foreign key (project_id) references projects (project_id)
);

create index institute_id
    on projects (institute_id);

create table if not exists social_media
(
    media_id   int auto_increment
        primary key,
    media_name varchar(50) not null,
    constraint media_name
        unique (media_name)
);

create table if not exists users
(
    user_id              int auto_increment
        primary key,
    media_id             int                  not null,
    username             varchar(40)          not null,
    first_name           varchar(50)          null,
    last_name            varchar(50)          null,
    country_of_birth     varchar(50)          null,
    country_of_residence varchar(50)          null,
    age                  int                  null,
    gender               varchar(20)          null,
    is_verified          tinyint(1) default 0 null,
    constraint media_id
        unique (media_id, username),
    constraint users_ibfk_1
        foreign key (media_id) references social_media (media_id)
);

create table if not exists posts
(
    post_id          int auto_increment
        primary key,
    user_id          int                      not null,
    media_id         int                      not null,
    content          text                     null,
    post_time        datetime                 not null,
    city             varchar(50)              null,
    state            varchar(50)              null,
    country          varchar(50)              null,
    likes            int unsigned default '0' null,
    dislikes         int unsigned default '0' null,
    has_multimedia   tinyint(1)   default 0   null,
    original_post_id int                      null,
    constraint user_id
        unique (user_id, post_time),
    constraint posts_ibfk_1
        foreign key (user_id) references users (user_id),
    constraint posts_ibfk_2
        foreign key (media_id) references social_media (media_id),
    constraint posts_ibfk_3
        foreign key (original_post_id) references posts (post_id)
);

create table if not exists analysis_results
(
    result_id     int auto_increment
        primary key,
    post_id       int                                 not null,
    project_id    int                                 not null,
    field_id      int                                 not null,
    value         text                                not null,
    analysis_time timestamp default CURRENT_TIMESTAMP null,
    constraint post_id
        unique (post_id, project_id, field_id),
    constraint analysis_results_ibfk_1
        foreign key (post_id) references posts (post_id),
    constraint analysis_results_ibfk_2
        foreign key (project_id) references projects (project_id),
    constraint analysis_results_ibfk_3
        foreign key (field_id) references analysis_fields (field_id)
);

create index field_id
    on analysis_results (field_id);

create index project_id
    on analysis_results (project_id);

create index media_id
    on posts (media_id);

create index original_post_id
    on posts (original_post_id);

create table if not exists reposts
(
    repost_id         int auto_increment
        primary key,
    original_post_id  int      not null,
    reposting_user_id int      not null,
    repost_time       datetime not null,
    constraint reposts_ibfk_1
        foreign key (original_post_id) references posts (post_id),
    constraint reposts_ibfk_2
        foreign key (reposting_user_id) references users (user_id)
);

create index original_post_id
    on reposts (original_post_id);

create index reposting_user_id
    on reposts (reposting_user_id);

