// scalastyle:off header.matches
/*
* Copyright (C) 2021. Huawei Technologies Co., Ltd.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
* */
/*
 * This file to You under the Apache License, Version 2.0;
 * you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 */

package org.apache.spark.mllib.stat.correlation

import org.apache.spark.internal.Logging
import org.apache.spark.mllib.linalg.{DenseVector, Matrix}
import org.apache.spark.rdd.RDD

object PearsonCorrelationUtil extends Logging {

  def computeDenseVectorCorrelation(rows: RDD[DenseVector]): Matrix = {
    null
  }

  def computeCorrelationMatrixFromUpperCovariance
  (upperCov: Array[Double], n: Int): Matrix = {
    null
  }

}
