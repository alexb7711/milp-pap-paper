# Parameter/Variable Definitions
## Constants 
$$
\begin{array}{llllc}
 	T            & : & \textrm{Time Horizon}                                                             & - & \mathbb{R} \\
	N            & : & \textrm{Number of total visits}                                                   & - & \mathbb{R} \\
	A            & : & \textrm{Number of buses in use}                                                   & - & \mathbb{R} \\
	Q            & : & \textrm{Number of chargers}                                                       & - & \mathbb{R} \\
	I            & : & \textrm{Final index}                                                              & - & \mathbb{R} \\
	M            & : & \textrm{An arbitrary very large upper bound value}                                & - & \mathbb{R} \\
	\Eta_{final} & : & \textrm{Final charge for bus } i \textrm{ at the end of the work day}             & - & \mathbb{R} \\
        \Xi          & : &                                                                                   & - & N(N-1)
\end{array}
$$

## Input Parameters
$$
\begin{array}{llllc}
	a_i          & : & \textrm{Arrival time of visit } i                                                 & - & N \times 1 \\
	m_q          & : & \textrm{Cost of a visit being assigned to charger } q                             & - & Q \times 1 \\
	\epsilon_q   & : & \textrm{Cost of using charger } q \textrm{ per unit time}                         & - & Q \times 1 \\
	r_q          & : & \textrm{Charge rate of charger } q \textrm{ per unit time}                            & - & Q \times 1 \\
	\Gamma_i     & : & \textrm{Array of visit id's}                                                      & - & N \times 1 \\
	\gamma_i     & : & \textrm{Array of values indicating the next index visit } i \textrm{ will arrive} & - & N \times 1 \\
	\tau_i       & : & \textrm{Time visit } i \textrm{ must leave the station}                           & - & Q \times 1 \\
	\lambda_i    & : & \textrm{Discharge of visit over route } i                                         & - & N \times 1 \\
	\kappa_i     & : & \textrm{Initial charge time for visit } i                                         & - & A \times 1 \\
	\xi_i        & : & \textrm{Final charge time for visit } i                                           & - & A \times 1 \\
\end{array}
$$

## Decision Variables
$$
\begin{array}{llllc}
	u_i         & : & \textrm{Initial charge time of visit } i                          & - & N \times 1     \\
	v_i         & : & \textrm{Assigned queue for visit } i                              & - & N \times 1     \\
	c_i         & : & \textrm{detach time from charger for  visit } i                   & - & N \times 1     \\
	p_i         & : & \textrm{Amount of time spent on charger for visit } i             & - & N \times 1     \\
	g_i         & : & \textrm{Linearization term for bilinear terms } g_i := p_i w_{iq} & - & N \times Q     \\
	\eta_i      & : & \textrm{Initial charge for visit } i                              & - & N \times 1     \\
	w_{iq}      & : & \textrm{Vector representation of queue assignment}                & - & N \times Q     \\
	\sigma_{ij} & : & u_i < u_j = 1 \textrm{ or } i \neq j = 0                          & - & \Xi \times \Xi \\
	\delta_{ij} & : & v_i < v_j = 1 \textrm{ or } i \neq j = 0                          & - & \Xi \times \Xi \\
\end{array}
$$

# Formulation
## Summation Notation
\begin{equation}\label{eq:objective}
	\sum_{i=1}^N \sum_{q=1}^Q \Big( w_i m_q + g_i \epsilon_q \Big)           \\
\end{equation}

\begin{equation*}
	\textrm{s.t.}                                                \\
\end{equation*}

\begin{subequations}
\begin{align}
	u_i - u_j - p_j - (\sigma_{ij} - 1)T \geq 1                           \label{subeq:time}         \\
	v_i - v_j - s_j - (\delta_{ij} - 1)S \geq 1                           \label{subeq:space}        \\
	\sigma_{ij} + \sigma_{ji} + \delta_{ij} + \delta_{ji} \geq 1          \label{subeq:valid_pos}    \\
	\sigma_{ij} + \sigma_{ji} \leq 1                                      \label{subeq:sigma}        \\
	\delta_{ij} + \delta_{ji} \leq 1                                      \label{subeq:delta}        \\
	p_i + u_i = c_i                                                       \label{subeq:detach}       \\
	a_i \leq u_i \leq (T - p_i)                                           \label{subeq:valid_starts} \\
	c_i \leq \tau_i                                                       \label{subeq:valid_depart} \\
	\eta_i + \sum_{q=1}^Q g_{iq} r_q \leq 1                        \label{subeq:max_charge}   \\
	\eta_i + \sum_{q=1}^Q g_{iq} r_q - \lambda_i \geq 0            \label{subeq:min_charge}   \\
	\eta_i + \sum_{q=1}^Q g_{iq} r_q - \lambda_i = \eta_{\gamma_i} \label{subeq:next_charge}  \\
	p_i \geq g_{iq}                                                       \label{subeq:gpgret}       \\
	p_i \leq g_{iq} - (1 - w_{iq})M                                       \label{subeq:gpsmol}       \\
	Mw_{iq} \geq g_{iq}                                                   \label{subeq:gwgret}       \\
	0 \leq g_{iq}                                                         \label{subeq:gwsmol}       \\
	\sum_{q=1}^Q w_{iq} = 1                                               \label{subeq:wmax}         \\
\end{align}
\end{subequations}

Where the objective function \eqref{eq:objective} is the summation over the cost of assignment of bus visit $i$ to charger $q$ and the usage of charger $q$. \eqref{subeq:time} and \eqref{subeq:space} are big M constraints to ensure bus visit $i$ is not overlapping another bus $j$ in either time or space. \eqref{subeq:valid_pos} is similar to \eqref{subeq:time} and \eqref{subeq:space} in the sense that it verifies that the bus visit $i$ is not overlapping bus visit $j$ in either time or space, but it also enforces that at least one of the states must be true. \eqref{subeq:sigma} and \eqref{subeq:delta} are set in place to prevent bus visit $i$ from being assigned to multiple positions in time or space, respectively. In other words, \eqref{subeq:time}, \eqref{subeq:space}, \eqref{subeq:valid_pos}, \eqref{subeq:sigma}, and \eqref{subeq:delta} are used together to ensure the bus visit is placed in a single valid position in both time (not encroaching on the bus in front or behind of it in the queue) and space (not allowing more than one bus to reside in the same physical space).

Constraints \eqref{subeq:detach}, \eqref{subeq:valid_starts}, and \eqref{subeq:valid_depart} are used to enforce time constraints. \eqref{subeq:detach} states that the initial charge time plus the time on the charger is the detach time. \eqref{subeq:valid_starts} states that the arrival time is less than the initial charge time and that the initial charge time is sufficient for the bus to be on for the allotted time. \eqref{subeq:valid_depart} enforces that the detach time of bus visit $i$ is before (or at the same as) the departure time. Constraint \eqref{subeq:wmax} is used to enforce that only a single charger may be chosen for bus visit $i$.

The set of constraints (\eqref{subeq:max_charge}, \eqref{subeq:min_charge}, and \eqref{subeq:next_charge}) are the linear battery dynamic constraints. \eqref{subeq:max_charge} does not allow bus visit $i$ to over charge, \eqref{subeq:min_charge} does not allow the bus to be undercharged as to ensure that the bus can complete its route, and \eqref{subeq:next_charge} is the linking item that sets the initial charge for bus visit $i$'s next visit.

The final set of constraints(\eqref{subeq:gpgret}, \eqref{subeq:gpsmol}, \eqref{subeq:gwgret}, and \eqref{subeq:gwsmol}), are used to linearise the bilinear term $p_i*w_{iq}$ by using big M constraints. 

## Matrix Notation
There are a few things to note:

* We want to convert this problem to standard LP, for our problem we will mainly be concerned with
	* Inequality of $\geq$ form
* We will be formulating the equation in the form $Ax = b$ and $Ax \geq b$ where
	* $A$ is a $n \times m$ matrix
	* $x$ is a $m \times 1$ vector
	* $b$ is a $n \times 1$ vector

### Matrix Deconstruction
The constraint matrix $A$ will be broken down into two parts: $A_{eq}$ for all the equality constraints and $A_{ineq}$ for all the inequality constraints. Both $A_{eq}$ and $A_{ineq}$ formulated with two sub-matrices $A_{pack}$ and $A_{dynamics}$ to represent the portion of the matrix that is utilized for the box packing constraints and the battery dynamics constraints, respectively. For example, $A_{eq}$ will be represented in the following manner

$$
A_{eq} = 
\begin{bmatrix}
	A_{\textrm{pack}}     \\
	A_{\textrm{dynamics}} \\
\end{bmatrix}_{eq}
$$

Where we can define the full equality as:

$$
\begin{array}{c}
	\begin{bmatrix}
		A_{\textrm{pack}}     \\
		A_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq}
	\begin{bmatrix}
		x_{\textrm{pack}}     \\
		x_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq} = 
	\begin{bmatrix}
		b_{\textrm{pack}}     \\
		b_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq} \\
	\\	
	A_{eq} x_{eq} = b_{eq} \\
\end{array}
$$

Similarly for the inequality constraints:

$$
\begin{bmatrix}
	A_{\textrm{pack}}     \\
	A_{\textrm{dynamics}} \\
\end{bmatrix}_{ineq}
\begin{bmatrix}
	x_{\textrm{pack}}     \\
	x_{\textrm{dynamics}} \\
\end{bmatrix}_{ineq} \geq 
\begin{bmatrix}
	b_{\textrm{pack}}     \\
	b_{\textrm{dynamics}} \\
\end{bmatrix}_{ineq}
$$

Finally, the entire constraint formulation will be written as:

\begin{subequations}
\begin{align}
	\begin{bmatrix}
		A_{\textrm{pack}}     \\
		A_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq}
	\begin{bmatrix}
		x_{\textrm{pack}}     \\
		x_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq} = 
	\begin{bmatrix}
		b_{\textrm{pack}}     \\
		b_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq} \\
	\begin{bmatrix}
		A_{\textrm{pack}}     \\
		A_{\textrm{dynamics}} \\
	\end{bmatrix}_{ineq}
	\begin{bmatrix}
		x_{\textrm{pack}}     \\
		x_{\textrm{dynamics}} \\
	\end{bmatrix}_{ineq} \geq 
	\begin{bmatrix}
		b_{\textrm{pack}}     \\
		b_{\textrm{dynamics}} \\
	\end{bmatrix}_{ineq}
\end{align}
\end{subequations}

## Formulating $A_{pack}$
### Formulating $A_{pack_{eq}}$
The components that make up the equality constraints for the box packing problem are:

* $p_i + u_i = c_i$
* $\sum_{q=1}^Q w_{iq} = 1$

Placing them together in $A_{eq}$ results in:

\begin{equation}	
\begin{array}{c}
	A_{eq} = 
	\begin{bmatrix}
		A_{detach_{N \times 2N}}    & \mathbb{0}_{N \times NQ} \\
		\mathbb{0}_{N \times 2N} & A_{w_{N \times NQ}}          \\
		\mathbb{0}_{N \times 2N} & A_{v_{N \times NQ}}          \\
	\end{bmatrix}_{3N \times (2N + NQ)}
	x_{eq} = 
	\begin{bmatrix}
		p_{i_{N \times 1}} \\
		u_{i_{N \times 1}} \\
		w_{iq_{NQ \times 1}} \\
	\end{bmatrix}_{2N + NQ}
	b_{eq} =
	\begin{bmatrix}
		c_{i_{N \times 1}} \\
		\mathbb{1}_{N \times 1} \\
		v_{i_{N \times 1}} \\
	\end{bmatrix}_{3N \times 1} \\
	\\
	\begin{bmatrix}
		A_{detach_{N \times 2N}}    & \mathbb{0}_{N \times NQ} \\
		\mathbb{0}_{N \times 2N} & A_{w_{N \times NQ}}          \\
		\mathbb{0}_{N \times 2N} & A_{v_{N \times NQ}}          \\
	\end{bmatrix}
	\begin{bmatrix}
		p_{i_{N \times 1}} \\
		u_{i_{N \times 1}} \\
		w_{iq_{NQ \times 1}} \\
	\end{bmatrix}
	=
	\begin{bmatrix}
		c_{i_{N \times 1}} \\
		\mathbb{1}_{N \times 1} \\
		v_{i_{N \times 1}} \\
	\end{bmatrix}
\end{array}
\end{equation}

Where 

### Formulating $A_{pack_{ineq}}$
The components that make up the inequality constraints for the box packing problem are

* $u_j - u_i - p_i - (\sigma_{ij} - 1)T \geq 1$
* $v_j - v_i - s_i - (\delta_{ij} - 1)S \geq 1$
* $\sigma_{ij} + \sigma{ji} + \delta_{ij} + \delta_{ji} \geq 1$
* $\sigma_{ij} + \sigma_{ji} \leq 1$
* $\delta_{ij} + \delta_{ji} \leq 1$
* $a_i \leq c_i \leq (T - p_i)$
* $c_i \leq \tau_i$
* $p_i \geq g_{iq}$
* $p_i \leq g_{iq} - (1 - w_{iq})M$
* $Mw_{iq} \geq g_{iq}$
* $0 \leq g_{iq}$

$A_{ineq}$ takes the form of:

\scriptsize
\begin{equation}	
\begin{array}{c}
	A_{ineq} =
	\begin{bmatrix}
		A_{time_{\Xi \times (2\Xi + 2N)}}   & \mathbb{0}_{\Xi \times (3\Xi + 4N + 3NQ)} & \cdots                                    & \cdots                       & \cdots                              & \cdots                          & \cdots                    & \cdots                & \cdots                    \\
		\mathbb{0}_{\Xi \times (2\Xi + 2N)} & A_{queue_{\Xi \times (2\Xi + 2N)}}        & \mathbb{0}_{\Xi \times (\Xi + 2N)}        & \cdots                       & \cdots                              & \cdots                          & \cdots                    & \cdots                & \cdots                    \\
		\mathbb{0}_{\Xi \times 2N}          & A_{\sigma_{\Xi \times \Xi}}               & \mathbb{0}_{\Xi \times (2N + 3NQ)}        & A_{\delta_{\Xi \times \Xi}}  & \mathbb{0}_{\Xi \times (2\Xi + 2N)} & \cdots                          & \cdots                    & \cdots                & \cdots                    \\
		\mathbb{0}_{\Xi \times 2N}          & -A_{\sigma_{\Xi \times \Xi}}              & \mathbb{0}_{\Xi \times (3\Xi + 4N + 3NQ)} & \cdots                       & \cdots                              & \cdots                          & \cdots                    & \cdots                & \cdots                    \\
		\mathbb{0}_{\Xi \times (2\Xi + 2N)} & \mathbb{0}_{\Xi \times (2N)}              & \cdots                                    & -A_{\delta_{\Xi \times \Xi}} & \mathbb{0}_{\Xi \times (2N + 3NQ)}  & \cdots                          & \cdots                    & \cdots                & \cdots                    \\
		\mathbb{0}_{N \times (4\Xi + 4N)}   & \cdots                                    & \cdots                                    & \cdots                       & -A_{a_{N \times N}}                 & \mathbb{0}_{N \times (N + 3NQ)} & \cdots                    & \cdots                & \cdots                    \\
		\mathbb{0}_{N \times (4\Xi + 5N)}   & \cdots                                    & \cdots                                    & \cdots                       & \cdots                              & -A_{c_{N \times N}}             & \mathbb{0}_{N \times 3NQ} & \cdots                & \cdots                    \\
		\mathbb{0}_{N \times (4\Xi + 5N)}   & \cdots                                    & \cdots                                    & \cdots                       & \cdots                              & -A_{c_{N \times N}}             & \mathbb{0}_{N \times 3NQ} & \cdots                & \cdots                    \\
		\mathbb{0}_{4N \times (4\Xi + 6N)}  & \cdots                                    & \cdots                                    & \cdots                       & \cdots                              & \cdots                          & A_{gg_{4N \times NQ}}     & A_{gw_{4N \times NQ}} & \mathbb{1}_{4N \times NQ} \\
	\end{bmatrix}_{(5\Xi + 7N) \times (4\Xi + 6N + 3NQ)}                                                                                                                                                                                                                                                                       \\
	x_{ineq} =
	\begin{bmatrix}
		u_{i_{N \times 1}} \\ p_{i_{N \times 1}} \\ \sigma_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ v_{i_{N \times 1}} \\ s_{i_{N \times 1}} \\ \delta_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ a_{i_{N \times 1}} \\ c_{i_{N \times 1}} \\ q_{iq_{NQ \times1}} \\w_{iq_{NQ \times 1}} \\ \mathbb{1}_{NQ \times 1} \\
	\end{bmatrix}_{(4\Xi + 6N + 3NQ) \times 1}
	b_{ineq} = 
	\begin{bmatrix}
		\mathbb{1}_{\Xi \times 1} \\ \mathbb{1}_{\Xi \times 1} \\ \mathbb{1}_{\Xi \times 1} \\ -\mathbb{1}_{\Xi \times 1} \\ -\mathbb{1}_{\Xi \times 1} \\ -c_{i_{N \times N}} \\ -(T-p_i)_{N \times N} \\ -\tau_{i_{N \times N}} \\ -p_{i_{N \times 1}} \\ p_{i_{N \times 1}} \\ \mathbb{0}_{2N \times 1} \\
	\end{bmatrix}_{(5\Xi + 7N) \times 1}
\end{array}
\end{equation}	
\normalsize 

## Formulating $A_{dynamics}$
### Formulating $A_{dynamics_{eq}}$
The components that make up the equality constraint for the dynamics problem are

* $\eta_{\gamma_i} = \eta_i + g_{iq} r_q - \lambda_i$

$A_{dynamics}$ takes the form of:

\begin{equation}
\begin{array}{c}
	A_{eq} =
	\begin{bmatrix}
		A_{\textrm{init charge}_{N \times N}}       & \mathbb{0}_{N \times (N+NQ)} \\
		A_{\textrm{next charge}_{N \times 2N + NQ}} & \cdots                       \\
	\end{bmatrix}_{2N \times (2N + NQ)} \\
	x_{eq} =
	\begin{bmatrix}
		\eta_{\i_{N \times 1}}   \\
		g_{iq_{NQ \times 1}}     \\
		\lambda_{i_{N \times 1}} \\
	\end{bmatrix}_{(2N + NQ) \times 1}
	b_{eq} =
	\begin{bmatrix}
		\eta_{i_{N \times 1}} \\	
		\eta_{\gamma_{i}\; N \times 1} \\	
	\end{bmatrix}_{2N \times 1}
\end{array}
\end{equation}

## Formulating $A_{dynamics_{ineq}}$
The components that make up the inequality constraint are

* $\eta_i + \sum_{q=1}^Q g_{iq} r_q \leq 1$
* $\eta_i + \sum_{q=1}^Q g_{iq} r_q - \lambda_i \geq 0$
* $\eta_{I} \geq \Eta_{final}$

$A_{dyanmics_{ineq}}$ takes the form of:

\begin{equation}
\begin{array}{c}
	A_{ineq} = 
	\begin{bmatrix}
		-A_{\textrm{max charge}_{N \times (N+NQ)}} & \mathbb{0}_{N \times N}        \\
		A_{\textrm{min charge}_{N \times (2N+NQ)}} & \cdots                         \\
		A_{\textrm{last charge}_{N \times N}}      & \mathbb{0}_{N \times (N + NQ)} \\
	\end{bmatrix}_{3N \times (2N + NQ)} \\
	x_{ineq} =
	\begin{bmatrix} 
		\eta_{i_{N \times 1}} \\	
		g_{iq_{NQ \times 1}} \\
	\end{bmatrix}_{(2N + NQ) \times 1}
	b_{ineq} =
	\begin{bmatrix}
		-\mathbb{1}_{N + NQ \times 1} \\
		\mathbb{0}_{2N + NQ \times 1} \\
		\Eta_{final}*\mathbb{1}_{A \times 1} \\
	\end{bmatrix}_{3N \times 1}
\end{array}
\end{equation}

## Putting it back together
\begin{equation*}
\begin{array}{c}
	\begin{bmatrix}
		A_{\textrm{pack}}     \\
		A_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq}
	\begin{bmatrix}
		x_{\textrm{pack}}     \\
		x_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq} = 
	\begin{bmatrix}
		b_{\textrm{pack}}     \\
		b_{\textrm{dynamics}} \\
	\end{bmatrix}_{eq} \\
	\begin{bmatrix}
		A_{\textrm{pack}}     \\
		A_{\textrm{dynamics}} \\
	\end{bmatrix}_{ineq}
	\begin{bmatrix}
		x_{\textrm{pack}}     \\
		x_{\textrm{dynamics}} \\
	\end{bmatrix}_{ineq} \geq 
	\begin{bmatrix}
		b_{\textrm{pack}}     \\
		b_{\textrm{dynamics}} \\
	\end{bmatrix}_{ineq}
\end{array}
\end{equation*}

May also be represented as

\scriptsize
\begin{equation}
\begin{array}{c}
A_{eq} =
\begin{bmatrix}
	\begin{Bmatrix}
		A_{detach_{N \times 2N}}    & \mathbb{0}_{N \times NQ} \\
		\mathbb{0}_{N \times 2N} & A_{w_{N \times NQ}}          \\
		\mathbb{0}_{N \times 2N} & A_{v_{N \times NQ}}          \\
	\end{Bmatrix}_{3N \times (2N + NQ)} 
	\begin{Bmatrix}
		\mathbb{0}
	\end{Bmatrix}_{3N \times (2N + NQ)} \\
	\begin{Bmatrix}
		\mathbb{0}_{}
	\end{Bmatrix}_{NA \times (2N + NQ)}
	\begin{Bmatrix}
		A_{\textrm{next charge}_{N \times 2N + NQ}}
	\end{Bmatrix}_{NA \times (2N + NQ + A)} \\
\end{bmatrix}_{(3N + NA) \times (4N + NQ + A)} \\
x_{eq} = 
\begin{bmatrix}
	\begin{Bmatrix}
		p_{i_{N \times 1}} \\
		u_{i_{N \times 1}} \\
		w_{iq_{NQ \times 1}} \\
	\end{Bmatrix}_{2N + NQ} \\
	\begin{Bmatrix}
		\eta_{\Gamma_{i\; N \times 1}} \\
		g_{iq_{NQ \times 1}}           \\
		\lambda_{i_{N \times 1}}       \\
	\end{Bmatrix}_{(2N + NQ + A) \times 1}
\end{bmatrix}_{(4N + 2NQ + A) \times 1}
b_{eq} =
\begin{bmatrix}
	\begin{Bmatrix}
		c_{i_{N \times 1}} \\
		\mathbb{1}_{N \times 1} \\
		v_{i_{N \times 1}} \\
	\end{Bmatrix}_{3N \times 1} \\
	\begin{Bmatrix}
		\eta_{\gamma_{i}\; N \times 1} \\	
	\end{Bmatrix}_{N \times 1}
\end{bmatrix}_{4N \times 1} \\
\begin{bmatrix}
	\begin{Bmatrix}
		A_{detach_{N \times 2N}}    & \mathbb{0}_{N \times NQ} \\
		\mathbb{0}_{N \times 2N} & A_{w_{N \times NQ}}          \\
		\mathbb{0}_{N \times 2N} & A_{v_{N \times NQ}}          \\
	\end{Bmatrix}_{3N \times (2N + NQ)} 
	\begin{Bmatrix}
		\mathbb{0}
	\end{Bmatrix}_{3N \times (2N + NQ)} \\
	\begin{Bmatrix}
		\mathbb{0}_{}
	\end{Bmatrix}_{NA \times (2N + NQ)}
	\begin{Bmatrix}
		A_{\textrm{next charge}_{N \times 2N + NQ}}
	\end{Bmatrix}_{NA \times (2N + NQ + A)} \\
\end{bmatrix}
\begin{bmatrix}
	\begin{Bmatrix}
		p_{i_{N \times 1}} \\
		u_{i_{N \times 1}} \\
		w_{iq_{NQ \times 1}} \\
	\end{Bmatrix}_{2N + NQ} \\
	\begin{Bmatrix}
		\eta_{\Gamma_{i\; N \times 1}} \\
		g_{iq_{NQ \times 1}}           \\
		\lambda_{i_{N \times 1}}       \\
	\end{Bmatrix}_{(2N + NQ + A) \times 1}
\end{bmatrix}
=
\begin{bmatrix}
	\begin{Bmatrix}
		c_{i_{N \times 1}} \\
		\mathbb{1}_{N \times 1} \\
		v_{i_{N \times 1}} \\
	\end{Bmatrix}_{3N \times 1} \\
	\begin{Bmatrix}
		\eta_{\gamma_{i}\; N \times 1} \\	
	\end{Bmatrix}
\end{bmatrix}_{4N \times 1}
\end{array}
\end{equation}

\begin{equation}
\begin{array}{c}
	A_{ineq} =
	\begin{bmatrix}
		\begin{Bmatrix}
			A_{time_{\Xi \times (2\Xi + 2N)}}   & \mathbb{0}_{\Xi \times (3\Xi + 4N)} & \cdots                              & \cdots                       & \cdots                            & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times (2\Xi + 2N)} & A_{queue_{\Xi \times (2\Xi + 2N)}}  & \mathbb{0}_{\Xi \times (\Xi + 2N)}  & \cdots                       & \cdots                            & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times 2N}          & A_{\sigma_{\Xi \times \Xi}}         & \mathbb{0}_{\Xi \times (\Xi + 2N)}  & A_{\delta_{\Xi \times \Xi}}  & \mathbb{0}_{\Xi \times (2\Xi + 2N)} & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times 2N}          & -A_{\sigma_{\Xi \times \Xi}}        & \mathbb{0}_{\Xi \times (5\Xi + 4N)} & \cdots                       & \cdots                            & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times (2\Xi + 2N)} & \mathbb{0}_{\Xi \times (2N)}  & \cdots                              & -A_{\delta_{\Xi \times \Xi}} & \mathbb{0}_{\Xi \times (\Xi + 2N)}        & \cdots              & \cdots \\
			\mathbb{0}_{N \times (4\Xi + 4N)}   & \cdots                              & \cdots                              & \cdots                       & -A_{a_{N \times N}}               & \cdots              & \cdots \\
			\mathbb{0}_{N \times (4\Xi + 5N)}   & \cdots                              & \cdots                              & \cdots                       & \cdots                            & -A_{c_{N \times N}} & \cdots \\
			\mathbb{0}_{N \times (4\Xi + 5N)}   & \cdots                              & \cdots                              & \cdots                       & \cdots                            & -A_{c_{N \times N}} & \cdots \\
			\mathbb{0}_{4N \times N}            & A_{gp_{4N \times \Xi}}              & \mathbb{0}_{4N \times (4\Xi + 3N)}  & \cdots                       & \cdots                            & \cdots              & A_{gw_{4N \times \Xi}} 
		\end{Bmatrix}_{(5\Xi + 7N) \times (5\Xi + 6N)}
		\begin{Bmatrix}
			\mathbb{0}
		\end{Bmatrix}_{(5 \Xi + 6N) \times (3N + NQ)} \\
		\begin{Bmatrix} 
			\mathbb{0}
		\end{Bmatrix}_{3N \times (5\Xi + 6N)}	
		\begin{Bmatrix}
			-A_{\textrm{max charge}_{N \times (N+NQ)}} & \mathbb{0}_{N \times N}                    & \mathbb{0}_{N \times N}                \\
								  & A_{\textrm{min charge}_{N \times (2N+NQ)}} & \mathbb{0}_{N \times N}                \\
			\mathbb{0}_{N \times (2N + NQ)}           & \cdots                                     & A_{\textrm{last charge}_{A \times A}} \\
		\end{Bmatrix}_{3N \times (3N + NQ)} \\
	\end{bmatrix} \\
	x_{ineq} =
	\begin{bmatrix}
		\begin{Bmatrix}
			u_{i_{N \times 1}} \\ p_{i_{N \times 1}} \\ \sigma_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ v_{i_{N \times 1}} \\ s_{i_{N \times 1}} \\ \delta_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ a_{i_{N \times 1}} \\ c_{i_{N \times 1}} \\
		\end{Bmatrix}_{(4\Xi + 6N) \times 1} \\
		\begin{Bmatrix}
			\eta_{i_{N \times 1}} \\	
			g_{iq_{NQ \times 1}} \\
			\mathbb{1}_{A \times 1} \\
		\end{Bmatrix}_{(3N + NQ) \times 1}
	\end{bmatrix}_{(4\Xi + 9N + N) \times 1}
	b_{ineq} = 
	\begin{bmatrix}
		\begin{Bmatrix}
			u_{i_{N \times 1}} \\ p_{i_{N \times 1}} \\ \sigma_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ v_{i_{N \times 1}} \\ s_{i_{N \times 1}} \\ \delta_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ a_{i_{N \times 1}} \\ c_{i_{N \times 1}} \\
		\end{Bmatrix}_{(4\Xi + 3N) \times 1} \\
		\begin{Bmatrix}
			-\mathbb{1}_{N + NQ \times 1} \\
			\mathbb{0}_{2N + NQ \times 1} \\
			0.95*\mathbb{1}_{A \times 1} \\
		\end{Bmatrix}_{3N \times 1}
	\end{bmatrix}_{(4\Xi + 6N) \times 1} \\
	\begin{bmatrix}
		\begin{Bmatrix}
			A_{time_{\Xi \times (2\Xi + 2N)}}   & \mathbb{0}_{\Xi \times (3\Xi + 4N)} & \cdots                              & \cdots                       & \cdots                            & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times (2\Xi + 2N)} & A_{queue_{\Xi \times (2\Xi + 2N)}}  & \mathbb{0}_{\Xi \times (\Xi + 2N)}  & \cdots                       & \cdots                            & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times 2N}          & A_{\sigma_{\Xi \times \Xi}}         & \mathbb{0}_{\Xi \times (\Xi + 2N)}  & A_{\delta_{\Xi \times \Xi}}  & \mathbb{0}_{\Xi \times (2\Xi + 2N)} & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times 2N}          & -A_{\sigma_{\Xi \times \Xi}}        & \mathbb{0}_{\Xi \times (5\Xi + 4N)} & \cdots                       & \cdots                            & \cdots              & \cdots \\
			\mathbb{0}_{\Xi \times (2\Xi + 2N)} & \mathbb{0}_{\Xi \times (2N)}  & \cdots                              & -A_{\delta_{\Xi \times \Xi}} & \mathbb{0}_{\Xi \times (\Xi + 2N)}        & \cdots              & \cdots \\
			\mathbb{0}_{N \times (4\Xi + 4N)}   & \cdots                              & \cdots                              & \cdots                       & -A_{a_{N \times N}}               & \cdots              & \cdots \\
			\mathbb{0}_{N \times (4\Xi + 5N)}   & \cdots                              & \cdots                              & \cdots                       & \cdots                            & -A_{c_{N \times N}} & \cdots \\
			\mathbb{0}_{N \times (4\Xi + 5N)}   & \cdots                              & \cdots                              & \cdots                       & \cdots                            & -A_{c_{N \times N}} & \cdots \\
			\mathbb{0}_{4N \times N}            & A_{gp_{4N \times \Xi}}              & \mathbb{0}_{4N \times (4\Xi + 3N)}  & \cdots                       & \cdots                            & \cdots              & A_{gw_{4N \times \Xi}} 
		\end{Bmatrix}_{(5\Xi + 7N) \times (5\Xi + 6N)}                                                                                                                                                            
		\begin{Bmatrix}
			\mathbb{0}
		\end{Bmatrix}_{(5 \Xi + 6N) \times (3N + NQ)} \\
		\begin{Bmatrix} 
			\mathbb{0}
		\end{Bmatrix}_{3N \times (5\Xi + 6N)}	
		\begin{Bmatrix}
			-A_{\textrm{max charge}_{N \times (N+NQ)}} & \mathbb{0}_{N \times N}                    & \mathbb{0}_{N \times N}                \\
								  & A_{\textrm{min charge}_{N \times (2N+NQ)}} & \mathbb{0}_{N \times N}                \\
			\mathbb{0}_{N \times (2N + NQ)}           & \cdots                                     & A_{\textrm{last charge}_{A \times A}} \\
		\end{Bmatrix}
	\end{bmatrix}  \\
	\begin{bmatrix}
		\begin{Bmatrix}
			u_{i_{N \times 1}} \\ p_{i_{N \times 1}} \\ \sigma_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ v_{i_{N \times 1}} \\ s_{i_{N \times 1}} \\ \delta_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ a_{i_{N \times 1}} \\ c_{i_{N \times 1}} \\
		\end{Bmatrix}_{(4\Xi + 6N) \times 1} \\
		\begin{Bmatrix}
			\eta_{i_{N \times 1}} \\	
			g_{iq_{NQ \times 1}} \\
			\mathbb{1}_{A \times 1} \\
		\end{Bmatrix}_{(3N + NQ) \times 1}
	\end{bmatrix}
	= 
	\begin{bmatrix}
		\begin{Bmatrix}
			u_{i_{N \times 1}} \\ p_{i_{N \times 1}} \\ \sigma_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ v_{i_{N \times 1}} \\ s_{i_{N \times 1}} \\ \delta_{ij_{\Xi \times 1}} \\ \mathbb{1}_{\Xi \times 1} \\ a_{i_{N \times 1}} \\ c_{i_{N \times 1}} \\
		\end{Bmatrix}_{(4\Xi + 3N) \times 1} \\
		\begin{Bmatrix}
			-\mathbb{1}_{N + NQ \times 1} \\
			\mathbb{0}_{2N + NQ \times 1} \\
			0.95*\mathbb{1}_{A \times 1} \\
		\end{Bmatrix}_{3N \times 1}
	\end{bmatrix}
\end{array}
\end{equation}
