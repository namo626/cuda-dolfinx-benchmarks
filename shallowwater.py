"""Contains forms representing the most intensive portion of Jorgen's 3-step Navier-Stokes solver - the tentative step."""

import basix.ufl
import ufl
from ufl import dx
from dolfinx import fem as fe
from dolfinx import default_scalar_type

from swemnics.problems import SlopedBeachProblem
from swemnics import solvers as Solvers
import numpy as np

NEEDS_DOMAIN=False

def get_forms(degree=2, res=100):
    """Return shallow water forms for a given polynomial degree."""
    dt = 600
    t = 0
    t_f = 7*24*60*60#24*7
    nt = int(np.ceil(t_f/dt))
    #friction law either quadratic or linear
    fric_law = 'mannings'
    #choose solution variable, either h or eta or flux
    sol_var = 'h'
    nx=12
    ny=6*res
    x1=13800
    y1=7200*res

    prob = SlopedBeachProblem(dt=dt,nt=nt,ny=ny,nx=nx,y1=y1,x1=x1,friction_law=fric_law,solution_var=sol_var,wd_alpha=0.36,wd=True)
    p_degree = [1,1]
    theta=1
    solver = Solvers.DGImplicit(prob,theta,p_degree=p_degree,make_tangent=True)
    L = solver.F
    a = ufl.derivative(L, solver.u)
    return a, L



