/*
 * Tencent is pleased to support the open source community by making BK-BASE 蓝鲸基础平台 available.
 *
 * Copyright (C) 2021 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * BK-BASE 蓝鲸基础平台 is licensed under the MIT License.
 *
 * License for BK-BASE 蓝鲸基础平台:
 * --------------------------------------------------------------------
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

-- 数据模型 --

SET NAMES utf8;
use bkdata_meta;

# 模型构建
CREATE TABLE IF NOT EXISTS `dmm_model_info` (
    model_id int(11) NOT NULL AUTO_INCREMENT COMMENT '模型ID',
    model_name varchar(255) NOT NULL COMMENT '模型名称，英文字母加下划线，全局唯一',
    model_alias varchar(255) NOT NULL COMMENT '模型别名',
    model_type varchar(32) NOT NULL COMMENT '模型类型，可选事实表、维度表',
    project_id int(11) NOT NULL COMMENT '项目ID',
    description text NULL COMMENT '模型描述',
    publish_status varchar(32) NOT NULL COMMENT '发布状态，可选 developing/published/re-developing',
    active_status varchar(32) NOT NULL DEFAULT 'active' COMMENT '可用状态, active/disabled/conflicting',
    # 主表信息
    table_name varchar(255) NOT NULL COMMENT '主表名称',
    table_alias varchar(255) NOT NULL COMMENT '主表别名',
    step_id int(11) NOT NULL DEFAULT 0 COMMENT '模型构建&amp;发布完成步骤',
    latest_version_id varchar(64) NULL COMMENT '模型最新发布版本ID',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`model_id`),
    CONSTRAINT `dmm_model_info_unique_model_name` UNIQUE(model_name)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型主表';
CREATE TABLE IF NOT EXISTS `dmm_model_top` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '主键Id',
    model_id int(11) NOT NULL COMMENT '模型ID',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型用户置顶表';
CREATE TABLE IF NOT EXISTS `dmm_model_field` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    model_id int(11) NOT NULL COMMENT '模型ID',
    field_name varchar(255) NOT NULL COMMENT '字段名称',
    field_alias varchar(255) NOT NULL COMMENT '字段别名',
    field_type varchar(32) NOT NULL COMMENT '数据类型，可选 long/int/...',
    field_category varchar(32) NOT NULL COMMENT '字段类型，可选维度、度量',
    is_primary_key tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否是主键 0：否，1：是',
    description text NULL COMMENT '字段描述',
    field_constraint_content text NULL COMMENT '字段约束',
    field_clean_content text NULL COMMENT '清洗规则',
    origin_fields text NULL COMMENT '计算来源字段，若有计算逻辑，则该字段有效',
    field_index int(11) NOT NULL COMMENT '字段位置',
    source_model_id int(11) NULL COMMENT '来源模型，若有则为扩展字段，目前仅针对维度扩展字段使用',
    source_field_name varchar(255) NULL COMMENT '来源字段，若有则为扩展字段，目前仅针对维度扩展字段使用',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    CONSTRAINT `dmm_model_field_unique_model_field` UNIQUE(model_id, field_name)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型字段表';
CREATE TABLE IF NOT EXISTS `dmm_model_relation` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    model_id int(11) NOT NULL COMMENT '模型ID',
    field_name varchar(255) NOT NULL COMMENT '字段名称',
    related_model_id int(11) NOT NULL COMMENT '关联模型ID',
    related_field_name varchar(255) NOT NULL COMMENT '关联字段名称',
    related_method varchar(32) NOT NULL COMMENT '关联方式，可选 left-join/inner-join/right-join',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    CONSTRAINT `dmm_model_relation_unique_model_relation` UNIQUE(model_id, related_model_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型关系表';
-- 字典表
CREATE TABLE IF NOT EXISTS `dmm_field_constraint_config` (
    constraint_id varchar(64) NOT NULL COMMENT '字段约束ID，可选值value_range/value_enum/not_include/include/start_with/end_with/regex/regex_email...',
    constraint_type varchar(32) NOT NULL COMMENT '约束类型，可选general/specific',
    constraint_name varchar(64) NOT NULL COMMENT '约束名称，可选值范围/值枚举/不包含/开头是/结尾是/正则/邮箱...',
    constraint_value text NULL COMMENT '约束规则，与数据质量打通，用于生成质量检测规则',
    validator text NULL COMMENT '约束规则校验',
    description text NULL COMMENT '字段约束说明',
    editable tinyint(1) NOT NULL COMMENT '是否可以编辑 0：不可编辑，1：可以编辑',
    allow_field_type text NULL COMMENT '允许的字段数据类型',
    PRIMARY KEY (`constraint_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='字段约束表';
CREATE TABLE IF NOT EXISTS `dmm_model_calculation_atom` (
    model_id int(11) NOT NULL COMMENT '模型ID',
    project_id int(11) NOT NULL COMMENT '项目ID',
    calculation_atom_name varchar(255) NOT NULL COMMENT '统计口径名称，要求英文字母加下划线',
    calculation_atom_alias varchar(255) NOT NULL COMMENT '统计口径别名',
    origin_fields text NULL COMMENT '计算来源字段，若有计算逻辑，则该字段有效',
    description text NULL COMMENT '统计口径描述',
    field_type varchar(32) NOT NULL COMMENT '字段类型',
    calculation_content text NOT NULL COMMENT '统计方式',
    calculation_formula text NOT NULL COMMENT '统计SQL，例如：sum(price)',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`calculation_atom_name`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型统计口径表';
CREATE TABLE IF NOT EXISTS `dmm_model_calculation_atom_image` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '主键Id',
    model_id int(11) NOT NULL COMMENT '模型ID',
    project_id int(11) NOT NULL COMMENT '项目ID',
    calculation_atom_name varchar(255) NOT NULL COMMENT '统计口径名称，要求英文字母加下划线',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    CONSTRAINT `calculation_atom_image_unique_model_id_calculation_atom_name` UNIQUE(model_id, calculation_atom_name)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型统计口径影像表，对集市中统计口径的引用';
CREATE TABLE IF NOT EXISTS `dmm_model_indicator` (
    model_id int(11) NOT NULL COMMENT '模型ID',
    project_id int(11) NOT NULL COMMENT '项目ID',
    indicator_name varchar(255) NOT NULL COMMENT '指标名称，要求英文字母加下划线，不可修改，全局唯一',
    indicator_alias varchar(255) NOT NULL COMMENT '指标别名',
    description text NULL COMMENT '指标描述',
    calculation_atom_name varchar(255) NOT NULL COMMENT '统计口径名称',
    aggregation_fields text NOT NULL COMMENT '聚合字段列表，使用逗号隔开',
    filter_formula text NULL COMMENT '过滤SQL，例如：system="android" AND area="sea"',
    condition_fields text NULL COMMENT '过滤字段，若有过滤逻辑，则该字段有效',
    scheduling_type varchar(32) NOT NULL COMMENT '计算类型，可选 stream、batch',
    scheduling_content text NOT NULL COMMENT '调度内容',
    parent_indicator_name varchar(255) NULL COMMENT '默认为NULL，表示直接从明细表里派生，不为NULL，标识从其他指标派生',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`indicator_name`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型指标表';
CREATE TABLE IF NOT EXISTS `dmm_calculation_function_config` (
    function_name varchar(64) NOT NULL COMMENT 'SQL 统计函数名称',
    output_type varchar(32) NOT NULL COMMENT '输出字段类型',
    allow_field_type text NOT NULL COMMENT '允许的数据类型',
    PRIMARY KEY (`function_name`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='SQL 统计函数表';
CREATE TABLE IF NOT EXISTS `dmm_model_release` (
    version_id varchar(64) NOT NULL COMMENT '模型版本ID',
    version_log text NOT NULL COMMENT '模型版本日志',
    model_id int(11) NOT NULL COMMENT '模型ID',
    model_content text NOT NULL COMMENT '模型版本内容',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`version_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型发布版本';


# 模型应用
CREATE TABLE IF NOT EXISTS `dmm_model_instance` (
    instance_id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    project_id int(11) NOT NULL COMMENT '项目ID',
    model_id int(11) NOT NULL COMMENT '模型ID',
    version_id varchar(64) NOT NULL COMMENT '模型版本ID',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    -- 任务配置
    flow_id int(11) NOT NULL COMMENT '当前应用的 DataFlowID',
    PRIMARY KEY (`instance_id`),
    KEY `dmm_model_instance_model_version_id` (`model_id`, `version_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型实例表';
CREATE TABLE IF NOT EXISTS `dmm_model_instance_field` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    instance_id int(11) NOT NULL COMMENT '形如：main_xxxxxx',
    model_id int(11) NOT NULL COMMENT '模型ID',
    field_name varchar(255) NOT NULL COMMENT '输出字段',
    input_result_table_id varchar(255) NULL COMMENT '输入结果表',
    input_field_name varchar(255) NULL COMMENT '输入字段',
    application_clean_content text NULL COMMENT '应用阶段清洗规则',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `dmm_model_instance_unique_field` (`instance_id`, `field_name`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型实例字段表';
CREATE TABLE IF NOT EXISTS `dmm_model_instance_relation` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    instance_id int(11) NOT NULL COMMENT '形如：main_xxxxxx',
    model_id int(11) NOT NULL COMMENT '模型ID',
    related_model_id int(11) NOT NULL COMMENT '关联模型ID',
    field_name varchar(255) NOT NULL COMMENT '输出字段',
    input_result_table_id varchar(255) NOT NULL COMMENT '输入结果表',
    input_field_name varchar(255) NOT NULL COMMENT '输入字段',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `dmm_model_instance_unique_relation` (`instance_id`, `field_name`, `related_model_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型实例关联表';
CREATE TABLE IF NOT EXISTS `dmm_model_instance_table` (
    result_table_id varchar(255) NOT NULL COMMENT '主表ID',
    bk_biz_id int(11) NOT NULL COMMENT '业务ID',
    instance_id int(11) NOT NULL COMMENT '形如：main_xxxxxx',
    model_id int(11) NOT NULL COMMENT '模型ID',
    flow_node_id int(11) NULL COMMENT '原Flow节点ID',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`result_table_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型实例主表';
CREATE TABLE IF NOT EXISTS `dmm_model_instance_indicator` (
    result_table_id varchar(255) NOT NULL COMMENT '结果表ID',
    project_id int(11) NOT NULL COMMENT '项目ID',
    bk_biz_id int(11) NOT NULL COMMENT '业务ID',
    instance_id int(11) NOT NULL COMMENT '模型实例ID',
    model_id int(11) NOT NULL COMMENT '模型ID',
    parent_result_table_id int(11) NULL COMMENT '默认为空，直接从主表继承，不为空表示来源于其它指标实例ID',
    flow_node_id int(11) NULL COMMENT '原Flow节点ID',
    -- 来自模型定义的指标继承写入，可以重载
    calculation_atom_name varchar(255) NOT NULL COMMENT '统计口径名称',
    aggregation_fields text NOT NULL COMMENT '聚合字段列表，使用逗号隔开',
    filter_formula text NULL COMMENT '过滤SQL，例如：system="android" AND area="sea"',
    scheduling_type varchar(32) NOT NULL COMMENT '计算类型，可选 stream、batch',
    scheduling_content text NOT NULL COMMENT '调度内容',
    -- 通用配置
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`result_table_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型实例指标表';
CREATE TABLE IF NOT EXISTS `dmm_model_instance_source` (
    id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    instance_id int(11) NOT NULL COMMENT '模型实例ID',
    input_type varchar(255) NOT NULL COMMENT '输入表类型',
    input_result_table_id varchar(255) NOT NULL COMMENT '输入结果表',
    created_by varchar(50) NOT NULL COMMENT '创建者',
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by varchar(50) DEFAULT NULL COMMENT '更新者',
    updated_at timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `dmm_model_instance_unique_input` (`instance_id`, `input_result_table_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据模型实例输入表';

-- 指标模型变更

alter table dmm_model_relation add related_model_version_id varchar(64) NULL COMMENT '维度模型版本ID';

alter table dmm_model_indicator add hash varchar(64) NULL COMMENT '指标关键参数对应的hash值';