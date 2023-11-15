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

 -- 优化查询索引 --

SET NAMES utf8;
use bkdata_meta;

CREATE TABLE IF NOT EXISTS `project_model` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL COMMENT '项目ID',
  `model_id` varchar(255) NOT NULL COMMENT '结果表ID',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '关系是否有效',
  `action_id` varchar(255) NOT NULL COMMENT '动作ID',
  `created_at` datetime NOT NULL COMMENT '创建人',
  `created_by` varchar(128) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_model_model_id_project_id_index` (`model_id`,`project_id`,`action_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8 COMMENT='项目中使用的模型信息'


CREATE TABLE IF NOT EXISTS `project_sample_set` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL COMMENT '项目ID',
  `sample_set_id` varchar(255) NOT NULL COMMENT '样本集ID',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT '关系是否有效',
  `action_id` varchar(255) NOT NULL COMMENT '动作ID',
  `created_at` datetime NOT NULL COMMENT '创建人',
  `created_by` varchar(128) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_sample_set_sample_set_id_project_id_index` (`sample_set_id`,`project_id`,`action_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='项目中使用的样本集信息'
