MATLAB FUNCTIONS:
  ml_findBox1a
  ml_findBox1b
  ml_findBox1c
  ml_findBox1d
  ml_findBoxes
  m_demo

  * See m_demo for demo of how to use.
  * These are matlab interface for Mex files. These files also check the type/size/format of the inputs.
  * See individual files for instructions, or type 'help functionName' in Matlab

==========
C++ FUNCTIONS:
  * Main: m_main.cpp -> calling tests
  * C++ functions: findBox1a, findBox1b, findBox1c, findBox1d, findBoxes2a, findBoxes2b
       See the files m_TreeNode1a, m_TreeNode1b, m_TreeNode1c, m_TreeNode1d, 
                     m_TreeNode2a, m_TreeNode2b.cpp for instructions.
  * Want to write your own function?
       - You do not need to rewrite branch and bound optimization.
       - You need to write a tree node class,
         the class should have the public fields: lb, ub and the public methods: cmpBnds, split()
       - Look at for eg m_TreeNode1a.cpp for an example


========
COMPILATION:
First run "mex -setup", then run:
mex  m_mexFindBox1a.cpp m_TreeNode1a.cpp m_TreeNode1.cpp m_utils.cpp m_BranchBound.cpp;
mex  m_mexFindBoxes.cpp m_TreeNode2a.cpp m_TreeNode1.cpp m_utils.cpp m_BranchBound.cpp m_TreeNode2b.cpp; 