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

set NAMES utf8;

update bkdata_meta.access_raw_data set data_category='alarm' where data_category='alert';
update bkdata_basic.access_raw_data set data_category='alarm' where data_category='alert';

update bkdata_meta.access_raw_data set data_category='operating_system' where data_category='performance';
update bkdata_basic.access_raw_data set data_category='operating_system' where data_category='performance';

update bkdata_meta.access_raw_data set data_category='sys_performance' where data_category='operating_system';
update bkdata_basic.access_raw_data set data_category='sys_performance' where data_category='operating_system';

use bkdata_meta;

INSERT INTO `dm_category_config`(`id`, `category_name`, `category_alias`, `parent_id`, `seq_index`, `icon`, `active`, `visible`, `created_by`, `created_at`, `updated_by`, `updated_at`, `description`) VALUES (47, 'sys_performance', '系统性能', 5, 1, NULL, 1, 1, 'admin', '2019-08-06 15:28:36', NULL, NULL, '系统性能');

use bkdata_basic;

INSERT INTO content_language_config (content_key, language, content_value, description) VALUES ('系统性能','en','system performance','');