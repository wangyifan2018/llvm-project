//===-- RISCVInstrFormatsV.td - RISC-V V Instruction Formats -*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file describes the RISC-V V extension instruction formats.
//
//===----------------------------------------------------------------------===//

class RISCVVFormat<bits<3> val> {
  bits<3> Value = val;
}
def OPIVV : RISCVVFormat<0b000>;
def OPFVV : RISCVVFormat<0b001>;
def OPMVV : RISCVVFormat<0b010>;
def OPIVI : RISCVVFormat<0b011>;
def OPIVX : RISCVVFormat<0b100>;
def OPFVF : RISCVVFormat<0b101>;
def OPMVX : RISCVVFormat<0b110>;
def OPCFG : RISCVVFormat<0b111>;

class RISCVMOP<bits<2> val> {
  bits<2> Value = val;
}
def MOPLDUnitStride   : RISCVMOP<0b00>;
def MOPLDIndexedUnord : RISCVMOP<0b01>;
def MOPLDStrided      : RISCVMOP<0b10>;
def MOPLDIndexedOrder : RISCVMOP<0b11>;

def MOPSTUnitStride   : RISCVMOP<0b00>;
def MOPSTIndexedUnord : RISCVMOP<0b01>;
def MOPSTStrided      : RISCVMOP<0b10>;
def MOPSTIndexedOrder : RISCVMOP<0b11>;

class RISCVLSUMOP<bits<5> val> {
  bits<5> Value = val;
}
def LUMOPUnitStride  : RISCVLSUMOP<0b00000>;
def LUMOPUnitStrideMask : RISCVLSUMOP<0b01011>;
def LUMOPUnitStrideWholeReg : RISCVLSUMOP<0b01000>;
def LUMOPUnitStrideFF: RISCVLSUMOP<0b10000>;
def SUMOPUnitStride  : RISCVLSUMOP<0b00000>;
def SUMOPUnitStrideMask : RISCVLSUMOP<0b01011>;
def SUMOPUnitStrideWholeReg : RISCVLSUMOP<0b01000>;

class RISCVWidth<bits<4> val> {
  bits<4> Value = val;
}
def LSWidth8     : RISCVWidth<0b0000>;
def LSWidth16    : RISCVWidth<0b0101>;
def LSWidth32    : RISCVWidth<0b0110>;
def LSWidth64    : RISCVWidth<0b0111>;

class RVInstSetiVLi<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> uimm;
  bits<5> rd;
  bits<10> vtypei;

  let Inst{31} = 1;
  let Inst{30} = 1;
  let Inst{29-20} = vtypei{9-0};
  let Inst{19-15} = uimm;
  let Inst{14-12} = OPCFG.Value;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Defs = [VTYPE, VL];
}

class RVInstSetVLi<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;
  bits<5> rd;
  bits<11> vtypei;

  let Inst{31} = 0;
  let Inst{30-20} = vtypei;
  let Inst{19-15} = rs1;
  let Inst{14-12} = OPCFG.Value;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Defs = [VTYPE, VL];
}

// set matrix type immediate
class RVInstSetMTypei<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rd;  // destination register
  bits<13> mtypei;  // immediate value for MTYPE

  let Inst{31-28} = 0b0000;
  let Inst{27-15} = mtypei;
  let Inst{14-12} = 0b100;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Defs = [MTYPE];
}
// set matrix type register
class RVInstSetMType<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-28} = 0b0001;
  let Inst{27-20} = 0;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b111;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Defs = [MTYPE];
}

// set tile size immediate
class RVInstSetTilei<bits<2> mit1, bits<2> mit2, bits<1> mit3, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<12> mleni;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = mit1;
  let Inst{25} = 1; // vm = 1
  let Inst{24-23} = mit2;
  let Inst{22-15} = mleni{11-4};
  let Inst{14-12} = 0b011;
  let Inst{11} = mit3;
  let Inst{10-7} = mleni{3-0};
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Defs = [TILEM];
}

// set tile size register
class RVInstSetTile<bits<5> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs1;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = 0;
  let Inst{25} = 1; // vm = 1
  let Inst{24-20} = mit;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b100;
  let Inst{11-7} = 0;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Defs = [TILEM];
}

class RVInstSetConvi<bits<2> mit1, bits<2> mit2, bits<1> mit3, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<6> mconvi1;
  bits<6> mconvi2;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = mit1;
  let Inst{25} = 1; // vm = 1
  let Inst{24-23} = mit2;
  let Inst{22-17} = mconvi2;
  let Inst{16-15} = mconvi1{5-4};
  let Inst{14-12} = 0b011;
  let Inst{11} = mit3;
  let Inst{10-7} = mconvi1{3-0};
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Defs = [TILEM];
}

class RVInstMoveT2T<bits<2> mit1, bits<2> mit2, bits<1> mit3, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<4> ts;
  bits<4> td;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = mit1;
  let Inst{25} = 1; // vm = 1
  let Inst{24-23} = mit2;
  let Inst{22-19} = 0;
  let Inst{18-15} = ts;
  let Inst{14-12} = 0b011;
  let Inst{11} = mit3;
  let Inst{10-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMoveV2T<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> vs;
  bits<4> td;

  let Inst{31-28} = 0b0010;
  let Inst{27-26} = 0;
  let Inst{25} = 1; // vm = 1
  let Inst{24-20} = vs;
  let Inst{19-15} = 0;
  let Inst{14-12} = 0b011;
  let Inst{11} = 0;
  let Inst{10-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMove2V2T<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> vs1;
  bits<5> vs2;
  bits<4> td;

  let Inst{31-28} = 0b1010;
  let Inst{27-26} = 0;
  let Inst{25} = 1; // vm = 1
  let Inst{24-20} = vs2;
  let Inst{19-15} = vs1;
  let Inst{14-12} = 0b000;
  let Inst{11} = 0;
  let Inst{10-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMoveT2V<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> vd;
  bits<4> ts;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = 0;
  let Inst{25} = 0; // vm = 0
  let Inst{24-19} = 0;
  let Inst{18-15} = ts;
  let Inst{14-12} = 0b100;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMoveI2T<bits<5> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs;
  bits<4> td;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = 0;
  let Inst{25} = 1; // vm = 1
  let Inst{24-20} = mit;
  let Inst{19-15} = rs;
  let Inst{14-12} = 0b100;
  let Inst{11} = 0;
  let Inst{10-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMLoad<bits<5> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs;
  bits<4> td;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = 0;
  let Inst{25} = 1; // vm = 1
  let Inst{24-20} = mit;
  let Inst{19-15} = rs;
  let Inst{14-12} = 0b100;
  let Inst{11} = 0;
  let Inst{10-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMStore<bits<5> mit, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> rs;
  bits<4> ts;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = 0;
  let Inst{25} = 1; // vm = 1
  let Inst{24-20} = mit;
  let Inst{19-15} = rs;
  let Inst{14-12} = 0b100;
  let Inst{11} = 0;
  let Inst{10-7} = ts;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMACC<bits<2> mit1, bits<2> mit2, bits<1> mit3, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<4> ts1;
  bits<4> ts2;
  bits<4> td;

  let Inst{31-28} = 0b0000;
  let Inst{27-26} = mit1;
  let Inst{25} = 1; // vm = 1
  let Inst{24-23} = mit2;
  let Inst{22-19} = ts2;
  let Inst{18-15} = ts1;
  let Inst{14-12} = 0b011;
  let Inst{11} = mit3;
  let Inst{10-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstSetVL<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31} = 1;
  let Inst{30-25} = 0b000000;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = OPCFG.Value;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Defs = [VTYPE, VL];
}

class RVInstVV<bits<6> funct6, RISCVVFormat opv, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs2;
  bits<5> vs1;
  bits<5> vd;
  bit vm;

  let Inst{31-26} = funct6;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = vs1;
  let Inst{14-12} = opv.Value;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstVX<bits<6> funct6, RISCVVFormat opv, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs2;
  bits<5> rs1;
  bits<5> vd;
  bit vm;

  let Inst{31-26} = funct6;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = opv.Value;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstV2<bits<6> funct6, bits<5> vs2, RISCVVFormat opv, dag outs, dag ins,
                string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs1;
  bits<5> vd;
  bit vm;

  let Inst{31-26} = funct6;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = opv.Value;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstIVI<bits<6> funct6, dag outs, dag ins, string opcodestr,
                string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs2;
  bits<5> imm;
  bits<5> vd;
  bit vm;

  let Inst{31-26} = funct6;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = imm;
  let Inst{14-12} = OPIVI.Value;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstV<bits<6> funct6, bits<5> vs1, RISCVVFormat opv, dag outs,
              dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs2;
  bits<5> vd;
  bit vm;

  let Inst{31-26} = funct6;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = vs1;
  let Inst{14-12} = opv.Value;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_OP_V.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstVLU<bits<3> nf, bit mew, RISCVLSUMOP lumop,
                bits<3> width, dag outs, dag ins, string opcodestr,
                string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs1;
  bits<5> vd;
  bit vm;

  let Inst{31-29} = nf;
  let Inst{28} = mew;
  let Inst{27-26} = MOPLDUnitStride.Value;
  let Inst{25} = vm;
  let Inst{24-20} = lumop.Value;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_LOAD_FP.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstVLS<bits<3> nf, bit mew, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> vd;
  bit vm;

  let Inst{31-29} = nf;
  let Inst{28} = mew;
  let Inst{27-26} = MOPLDStrided.Value;
  let Inst{25} = vm;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_LOAD_FP.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstVLX<bits<3> nf, bit mew, RISCVMOP mop, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs2;
  bits<5> rs1;
  bits<5> vd;
  bit vm;

  let Inst{31-29} = nf;
  let Inst{28} = mew;
  let Inst{27-26} = mop.Value;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = vd;
  let Inst{6-0} = OPC_LOAD_FP.Value;

  let Uses = [VTYPE, VL];
  let RVVConstraint = VMConstraint;
}

class RVInstVSU<bits<3> nf, bit mew, RISCVLSUMOP sumop,
                bits<3> width, dag outs, dag ins, string opcodestr,
                string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs1;
  bits<5> vs3;
  bit vm;

  let Inst{31-29} = nf;
  let Inst{28} = mew;
  let Inst{27-26} = MOPSTUnitStride.Value;
  let Inst{25} = vm;
  let Inst{24-20} = sumop.Value;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = vs3;
  let Inst{6-0} = OPC_STORE_FP.Value;

  let Uses = [VTYPE, VL];
}

class RVInstML<bits<6> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> td;

  let Inst{31-26} = funct6;
  let Inst{25} = 0;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = td;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMS<bits<6> funct6, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> ts3;

  let Inst{31-26} = funct6;
  let Inst{25} = 1; // store
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = ts3;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMM<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> ts2;
  bits<5> ts1;
  bits<5> accd;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = ts2;
  let Inst{19-15} = ts1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstADDSUB<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> acc1;
  bits<5> accd;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = 0;
  let Inst{19-15} = acc1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMEMULMX<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> acc1;
  bits<5> accd;
  bits<5> rs2;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = rs2;
  let Inst{19-15} = acc1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMEMULMI<bits<6> funct6, dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatI> {
  bits<5> accd;
  bits<5> acc1;
  bits<5> mimm5;

  let Inst{31-26} = funct6;
  let Inst{25} = 0;
  let Inst{24-20} = mimm5;
  let Inst{19-15} = acc1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMEMULMV<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> acc1;
  bits<5> accd;
  bits<5> vs2;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = vs2;
  let Inst{19-15} = acc1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMMACCMV<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs1;
  bits<5> accd;
  bits<5> vs2;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = vs2;
  let Inst{19-15} = vs1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMCVT<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> acc1;
  bits<5> accd;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = 0;
  let Inst{19-15} = acc1;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMCLR<bits<6> funct6, bit fp, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> accd;

  let Inst{31-26} = funct6;
  let Inst{25} = fp;
  let Inst{24-20} = 0;
  let Inst{19-15} = 0;
  let Inst{14-12} = 0b110;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}

class RVInstMOVE<bits<6> funct6, bit v2m, dag outs, dag ins,
               string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> acc1;
  bits<5> accd;
  bits<5> rs2;

  let Inst{31-26} = funct6;
  let Inst{25} = v2m;
  let Inst{24-20} = rs2;
  let Inst{19-15} = acc1;
  let Inst{14-12} = 0b101;
  let Inst{11-7} = accd;
  let Inst{6-0} = OPC_CUSTOM_2.Value;

  let Uses = [MTYPE, TILEM, TILEK, TILEN];
}


class RVInstVSS<bits<3> nf, bit mew, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> rs2;
  bits<5> rs1;
  bits<5> vs3;
  bit vm;

  let Inst{31-29} = nf;
  let Inst{28} = mew;
  let Inst{27-26} = MOPSTStrided.Value;
  let Inst{25} = vm;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = vs3;
  let Inst{6-0} = OPC_STORE_FP.Value;

  let Uses = [VTYPE, VL];
}

class RVInstVSX<bits<3> nf, bit mew, RISCVMOP mop, bits<3> width,
                dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatR> {
  bits<5> vs2;
  bits<5> rs1;
  bits<5> vs3;
  bit vm;

  let Inst{31-29} = nf;
  let Inst{28} = mew;
  let Inst{27-26} = mop.Value;
  let Inst{25} = vm;
  let Inst{24-20} = vs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = width;
  let Inst{11-7} = vs3;
  let Inst{6-0} = OPC_STORE_FP.Value;

  let Uses = [VTYPE, VL];
}
