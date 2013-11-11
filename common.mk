


R_CMD=$(R_HOME)/bin/Rscript
R_FLAG = --vanilla
RBASE_ENV=R_COMPILE_PKGS=0 R_ENABLE_JIT=0
RBYTECODE_ENV=R_COMPILE_PKGS=1 R_ENABLE_JIT=2

TERR_CMD=$(TERR_HOME)/bin/TERR

RBASE_HARNESS=${LEVEL}/utility/rbase_harness.R
RBYTECODE_HARNESS=${LEVEL}/utility/rbytecode_harness.R
ifndef REP
	REP=1
endif

#How many times a perf measurement is done
PERF_REP=1
PERF_TMP=_perf.tmp
PERF_CMD=perf stat -r $(PERF_REP) -x, -o $(PERF_TMP) --append
PERF_WARM_REP=2
PERF_TOTAL_REP=7
PERF_REPORT_CMD=python ${LEVEL}/utility/perfreport.py

default: base

base: ${PROG}.base
	
bytecode: ${PROG}.bytecode	

baseperf: ${PROG}.baseperf

bytecodeperf: ${PROG}.bytecodeperf

terrperf: ${PROG}.terrperf

%.base: %.R
	${RBASE_ENV} ${R_CMD} ${R_FLAG} ${RBASE_HARNESS} $< ${REP} ${PARA}
	
%.bytecode: %.R
	${RBYTECODE_ENV} ${R_CMD} ${R_FLAG} ${RBYTECODE_HARNESS} $< ${REP} ${PARA}

%.terr: %.R
	${TERR_CMD} -f ${RBASE_HARNESS} --args $< ${REP} ${PARA}

%.baseperf: %.R
	@echo ${PERF_WARM_REP} > ${PERF_TMP}
	${RBASE_ENV} ${PERF_CMD} ${R_CMD} ${R_FLAG} ${RBASE_HARNESS} $< ${PERF_WARM_REP} ${PARA}
	@echo ${PERF_TOTAL_REP} >> ${PERF_TMP}
	${RBASE_ENV} ${PERF_CMD} ${R_CMD} ${R_FLAG} ${RBASE_HARNESS} $< ${PERF_TOTAL_REP} ${PARA}
	${PERF_REPORT_CMD} < $(PERF_TMP)
	@rm -f  $(PERF_TMP)
	
%.bytecodeperf: %.R
	@echo ${PERF_WARM_REP} > ${PERF_TMP}
	${RBYTECODE_ENV} ${PERF_CMD} ${R_CMD} ${R_FLAG} ${RBYTECODE_HARNESS} $< ${PERF_WARM_REP} ${PARA}
	@echo ${PERF_TOTAL_REP} >> ${PERF_TMP}
	${RBYTECODE_ENV} ${PERF_CMD} ${R_CMD} ${R_FLAG} ${RBYTECODE_HARNESS} $< ${PERF_TOTAL_REP} ${PARA}
	${PERF_REPORT_CMD} < $(PERF_TMP)
	@rm -f  $(PERF_TMP)

	
%.terrperf: %.R
	@echo ${PERF_WARM_REP} > ${PERF_TMP}
	${PERF_CMD} ${TERR_CMD} -f ${RBASE_HARNESS} --args $< ${PERF_WARM_REP} ${PARA}
	@echo ${PERF_TOTAL_REP} >> ${PERF_TMP}
	${PERF_CMD} ${TERR_CMD} -f ${RBASE_HARNESS} --args $< ${PERF_TOTAL_REP} ${PARA}
	${PERF_REPORT_CMD} < $(PERF_TMP)
	@rm -f  $(PERF_TMP)